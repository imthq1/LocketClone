package SocialNetwork.SocialNetwork.service;

import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.data.redis.core.ValueOperations;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.thymeleaf.context.Context;

import java.security.SecureRandom;
import java.time.Duration;
import java.util.Locale;
import java.util.concurrent.TimeUnit;

@Service
@RequiredArgsConstructor
public class OtpRedisService {

    private final StringRedisTemplate redis;
    private final EmailService emailService; // dùng EmailService sẵn có

    // Cấu hình
    private static final Duration EXPIRE_IN = Duration.ofMinutes(5);
    private static final Duration RESEND_COOLDOWN = Duration.ofSeconds(60);
    private static final int MAX_ATTEMPTS = 5;

    private String normalize(String s) {
        return s == null ? "" : s.trim().toLowerCase(Locale.ROOT);
    }

    private String keyCode(String purpose, String email) {
        return "otp:code:" + normalize(purpose) + ":" + normalize(email);
    }
    private String keyAttempts(String purpose, String email) {
        return "otp:attempts:" + normalize(purpose) + ":" + normalize(email);
    }
    private String keyCooldown(String purpose, String email) {
        return "otp:cooldown:" + normalize(purpose) + ":" + normalize(email);
    }

    private String generateOtp6() {
        SecureRandom r = new SecureRandom();
        int code = 100000 + r.nextInt(900000);
        return Integer.toString(code);
    }

    public void sendOtp(String email, String purpose, String displayName) {
        final ValueOperations<String, String> ops = redis.opsForValue();
        final String kCool = keyCooldown(purpose, email);

        // Throttle gửi lại
        if (Boolean.TRUE.equals(redis.hasKey(kCool))) {
            Long remain = redis.getExpire(kCool, TimeUnit.SECONDS);
            long seconds = (remain != null && remain > 0) ? remain : 0;
            throw new IllegalStateException("Vui lòng thử lại sau " + seconds + " giây.");
        }

        // Tạo OTP (plaintext)
        final String otp = generateOtp6();

        // Lưu OTP plaintext với TTL
        final String kCode = keyCode(purpose, email);
        ops.set(kCode, otp, EXPIRE_IN);

        // Reset attempts về 0 (TTL trùng code)
        final String kAttempts = keyAttempts(purpose, email);
        ops.set(kAttempts, "0", EXPIRE_IN);

        // Set cooldown
        ops.set(kCool, "1", RESEND_COOLDOWN);

        // Gửi email (template dùng ${name} và ${value})
        final String subject = switch (normalize(purpose)) {
            case "register" -> "Mã xác thực đăng ký";
            case "login_2fa" -> "Mã đăng nhập";
            case "reset_password" -> "Mã khôi phục mật khẩu";
            default -> "Mã xác thực";
        };

        emailService.sendEmailFromTemplateSync(
                email,
                subject,
                "otp",
                (displayName != null && !displayName.isBlank()) ? displayName : email,
                otp
        );
    }

    public boolean verifyOtp(String email, String purpose, String otpInput, boolean deleteOnSuccess) {
        final ValueOperations<String, String> ops = redis.opsForValue();
        final String kCode = keyCode(purpose, email);
        final String kAttempts = keyAttempts(purpose, email);

        String storedOtp = ops.get(kCode);
        if (storedOtp == null) {
            return false;
        }

        // Lấy số lần sai
        int attempts = 0;
        try {
            String a = ops.get(kAttempts);
            if (a != null) attempts = Integer.parseInt(a);
        } catch (NumberFormatException ignored) {}

        if (attempts >= MAX_ATTEMPTS) {
            redis.delete(kCode);
            redis.delete(kAttempts);
            return false;
        }

        boolean ok = storedOtp.equals(otpInput);
        if (ok) {
            if (deleteOnSuccess) {
                redis.delete(kCode);
                redis.delete(kAttempts);
            }
            return true;
        } else {
            long ttlSec = Math.max(0, redis.getExpire(kCode, TimeUnit.SECONDS));
            ops.set(kAttempts, Integer.toString(attempts + 1), Duration.ofSeconds(ttlSec));
            return false;
        }
    }
}
