package SocialNetwork.SocialNetwork.controller;


import SocialNetwork.SocialNetwork.service.OtpRedisService;
import lombok.Data;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/auth/otp")
@RequiredArgsConstructor
public class OtpController {

    private final OtpRedisService otpService;

    @PostMapping("/send")
    public ResponseEntity<?> send(@RequestBody SendOtpRequest req) {
        try {
            otpService.sendOtp(req.getEmail(), req.getPurpose(), req.getDisplayName());
            return ResponseEntity.ok().build();
        } catch (IllegalStateException e) {
            return ResponseEntity.status(429).body(e.getMessage());
        }
    }

    @PostMapping("/verify")
    public ResponseEntity<?> verify(@RequestBody VerifyOtpRequest req) {
        boolean ok = otpService.verifyOtp(req.getEmail(), req.getPurpose(), req.getOtp(), true);
        if (ok) return ResponseEntity.ok().build();
        return ResponseEntity.badRequest().body("OTP không hợp lệ hoặc đã hết hạn");
    }

    @Data
    public static class SendOtpRequest {
        private String email;
        private String purpose;
        private String displayName;
    }

    @Data
    public static class VerifyOtpRequest {
        private String email;
        private String purpose;
        private String otp;
    }
}