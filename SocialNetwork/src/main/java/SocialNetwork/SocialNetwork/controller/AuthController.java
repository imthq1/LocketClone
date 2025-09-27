package SocialNetwork.SocialNetwork.controller;

import SocialNetwork.SocialNetwork.domain.Request.ReqDTO;
import SocialNetwork.SocialNetwork.domain.Request.ResLoginDTO;
import SocialNetwork.SocialNetwork.domain.Response.UserDTO;
import SocialNetwork.SocialNetwork.domain.User;
import SocialNetwork.SocialNetwork.service.SessionService;
import SocialNetwork.SocialNetwork.service.UserService;
import SocialNetwork.SocialNetwork.util.ApiMessage;
import SocialNetwork.SocialNetwork.util.RequestUtil;
import SocialNetwork.SocialNetwork.util.SecurityUtil;
import SocialNetwork.SocialNetwork.util.error.IdInValidException;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseCookie;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.web.bind.annotation.*;

import java.time.Duration;
import java.util.Optional;

@RestController
@RequestMapping("/api/v1")
public class AuthController {
    private final UserService userService;
    private final SecurityUtil securityUtil;
    private final SessionService sessionService;
    private final AuthenticationManagerBuilder authenticationManagerBuilder;
    // Tên cookie refresh token (cố định đường dẫn để chỉ gửi lên /auth/refresh & /auth/logout)
    private static final String RT_COOKIE = "refresh_token";
    private static final String RT_PATH   = "/api/auth";

    @Value("${imthang.jwt.refresh-token-validity-in-seconds:90000}")
    private long refreshTokenExpiration;
    public AuthController(UserService userService, AuthenticationManagerBuilder authenticationManagerBuilder,
                          SecurityUtil securityUtil, SessionService sessionService) {
        this.userService = userService;
        this.authenticationManagerBuilder = authenticationManagerBuilder;
        this.securityUtil = securityUtil;
        this.sessionService = sessionService;
    }
    @PostMapping("/auth/register")
    @ApiMessage("Register Account")
    public ResponseEntity<UserDTO> register(@RequestBody User user) throws IdInValidException {
        if(this.userService.getUserByEmail(user.getEmail())!=null){
            throw new IdInValidException("User has been exists!");
        }
        UserDTO userDTO=this.userService.CreateUser(user);
//        this.emailService.sendLinkVerify(user.getEmail(), user.getFullname());
        return ResponseEntity.ok().body(userDTO);
    }
    @GetMapping("/auth/account")
    @ApiMessage("get Account")
    public ResponseEntity<UserDTO> getAccount() throws IdInValidException {
        Optional<String> emailOpt = SecurityUtil.getCurrentUserLogin();
        if (emailOpt.isEmpty()) {
            throw new IdInValidException("User not logged in");
        }
        String email = emailOpt.get();
        User currentUserDB = userService.getUserByEmail(email);
        System.out.println("USER"+currentUserDB);
        if (currentUserDB == null) {
            throw new IdInValidException("User not found");
        }
        UserDTO userDTO = new UserDTO();
        userDTO.setId(currentUserDB.getId());
        userDTO.setEmail(currentUserDB.getEmail());
        userDTO.setFullname(currentUserDB.getFullname());
        userDTO.setAddress(currentUserDB.getAddress());
        userDTO.setImage(currentUserDB.getImageUrl());

        return ResponseEntity.ok(userDTO);
    }
    @PostMapping("/auth/login")
    @ApiMessage("Login Account")
    public ResponseEntity<ResLoginDTO> login(@RequestBody ReqDTO req,
                                             HttpServletRequest request) throws IdInValidException {

        User user = userService.getUserByEmail(req.getEmail());
        if (user == null) throw new IdInValidException("User hasn't exists!");

        var authenticationToken = new UsernamePasswordAuthenticationToken(req.getEmail(), req.getPassword());
        Authentication authentication = authenticationManagerBuilder.getObject().authenticate(authenticationToken);
        SecurityContextHolder.getContext().setAuthentication(authentication);

        var res = new ResLoginDTO();
        res.setUserLogin(new ResLoginDTO.UserLogin(user.getId(), user.getEmail(), user.getFullname()));

        String accessToken = securityUtil.createAcessToken(authentication.getName(), res);
        res.setAccessToken(accessToken);

        String refreshToken = securityUtil.createRefreshToken(user.getEmail(), res);

        String ip = RequestUtil.clientIp(request);
        String ua = RequestUtil.userAgent(request);
        sessionService.createSession(user, refreshToken, ua, ip, refreshTokenExpiration);

        ResponseCookie rtCookie = ResponseCookie.from(RT_COOKIE, refreshToken)
                .httpOnly(true)
                .secure(true)
                .sameSite("None")
                .path(RT_PATH)
                .maxAge(Duration.ofSeconds(refreshTokenExpiration))
                .build();

        return ResponseEntity.ok()
                .header(HttpHeaders.SET_COOKIE, rtCookie.toString())
                .body(res);
    }
    @PostMapping("/auth/refresh")
    public ResponseEntity<ResLoginDTO> refresh(@CookieValue(name = RT_COOKIE, required = false) String rtCookieVal)
            throws IdInValidException {

        if (rtCookieVal == null || rtCookieVal.isBlank()) {
            throw new IdInValidException("Missing refresh token");
        }

        var jwt = securityUtil.checkValidRefreshToken(rtCookieVal);
        var session = sessionService
                .findByRefreshToken(rtCookieVal)
                .orElseThrow(() -> new IdInValidException("Refresh session not found"));
        if (session.getExpiresAt().isBefore(java.time.Instant.now())) {
            sessionService.revokeByRefreshToken(rtCookieVal);
            throw new IdInValidException("Refresh token expired");
        }

        var res = new ResLoginDTO();
        res.setUserLogin(new ResLoginDTO.UserLogin(session.getUser().getId(),
                jwt.getSubject(), session.getUser().getFullname()));

        String newAccess = securityUtil.createAcessToken(jwt.getSubject(), res);
        res.setAccessToken(newAccess);

        String newRefresh = securityUtil.createRefreshToken(jwt.getSubject(), res);
        sessionService.rotateRefreshToken(session, newRefresh, refreshTokenExpiration);

        ResponseCookie rtCookie = ResponseCookie.from(RT_COOKIE, newRefresh)
                .httpOnly(true)
                .secure(true)
                .sameSite("None")
                .path(RT_PATH)
                .maxAge(Duration.ofSeconds(refreshTokenExpiration))
                .build();

        return ResponseEntity.ok()
                .header(HttpHeaders.SET_COOKIE, rtCookie.toString())
                .body(res);
    }

    @PostMapping("/auth/logout")
    public ResponseEntity<Void> logout(@CookieValue(name = RT_COOKIE, required = false) String rtCookieVal) {
        if (rtCookieVal != null && !rtCookieVal.isBlank()) {
            sessionService.revokeByRefreshToken(rtCookieVal);
        }
        ResponseCookie del = ResponseCookie.from(RT_COOKIE, "")
                .httpOnly(true).secure(true).sameSite("None")
                .path(RT_PATH).maxAge(0)
                .build();
        return ResponseEntity.noContent()
                .header(HttpHeaders.SET_COOKIE, del.toString())
                .build();
    }
}
