package SocialNetwork.SocialNetwork.domain;

import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;
import lombok.*;
import java.time.Instant;

@Entity
@Table(name = "sessions", indexes = {
        @Index(name = "idx_sessions_user_id", columnList = "user_id"),
        @Index(name = "idx_sessions_refresh_token", columnList = "refresh_token", unique = true),
        @Index(name = "idx_sessions_expires_at", columnList = "expires_at")
})
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Session {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;

    // MỖI SESSION THUỘC VỀ 1 USER
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id", nullable = false,
            foreignKey = @ForeignKey(name = "fk_sessions_user"))
    @ToString.Exclude
    @JsonBackReference("user_session")
    private User user;

    @Column(length = 255)
    private String deviceInfo;

    @Column(length = 64)
    private String ip;

    // Refresh token cho phiên này (đăng nhập đa thiết bị)
    @Column(name = "refresh_token", columnDefinition = "TEXT", nullable = false)
    private String refreshToken;

    // (tuỳ) có thể lưu access token hash/identifier nếu cần revoke nhanh
    // @Column(name = "access_token_hash", length = 128)
    // private String accessTokenHash;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    @Column(name = "expires_at", nullable = false)
    private Instant expiresAt;

    // (tuỳ) để tracking realtime/last seen
    // @Column(name = "last_active")
    // private Instant lastActive;

    @PrePersist
    public void beforeCreate() {
        if (this.createdAt == null) this.createdAt = Instant.now();
    }
}
