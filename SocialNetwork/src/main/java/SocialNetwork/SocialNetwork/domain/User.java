// User.java
package SocialNetwork.SocialNetwork.domain;

import SocialNetwork.SocialNetwork.util.SecurityUtil;
import com.fasterxml.jackson.annotation.JsonIgnore;
import jakarta.persistence.*;
import lombok.*;
import java.time.Instant;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "users", indexes = {
        @Index(name = "idx_users_email_unique", columnList = "email", unique = true)
})
@NoArgsConstructor
@AllArgsConstructor
@Builder
@Getter @Setter
public class User {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false, length = 190)
    private String email;

    @Column(length = 3)
    private String age;

    @Column(nullable = false)
    private String password;

    @Column(length = 120)
    private String fullname;

    private Instant createdAt;
    private Instant updatedAt;
    private String createdBy;
    private String updatedBy;

    @Column(length = 120)
    private String providerId;

    @Column(name = "image_url", columnDefinition = "TEXT")
    private String imageUrl;

    @Column(length = 255)
    private String address;

    // Session mapping giữ nguyên
    @OneToMany(
            mappedBy = "user",
            cascade = CascadeType.ALL,
            orphanRemoval = true,
            fetch = FetchType.LAZY
    )
    @ToString.Exclude
    private List<Session> sessions = new ArrayList<>();

    // Các yêu cầu kết bạn do user này GỬI
    @OneToMany(mappedBy = "requester", cascade = CascadeType.ALL, orphanRemoval = true)
    @ToString.Exclude
    private List<FriendRequest> friendRequestsSent = new ArrayList<>();

    // Các yêu cầu kết bạn do user này NHẬN
    @OneToMany(mappedBy = "addressee", cascade = CascadeType.ALL, orphanRemoval = true)
    @ToString.Exclude
    private List<FriendRequest> friendRequestsReceived = new ArrayList<>();

    @OneToMany(mappedBy = "user",cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonIgnore
    private List<Post> posts = new ArrayList<>();

    public void addSession(Session s) {
        sessions.add(s);
        s.setUser(this);
    }

    public void removeSession(Session s) {
        sessions.remove(s);
        s.setUser(null);
    }

    @PrePersist
    public void beforeCreate() {
        this.createdBy = SecurityUtil.getCurrentUserLogin().orElse("");
        this.createdAt = Instant.now();
    }

    @PreUpdate
    public void beforeUpdate() {
        this.updatedAt = Instant.now();
        this.updatedBy = SecurityUtil.getCurrentUserLogin().orElse("");
    }
}
