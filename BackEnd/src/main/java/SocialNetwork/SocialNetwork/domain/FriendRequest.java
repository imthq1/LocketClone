// FriendRequest.java
package SocialNetwork.SocialNetwork.domain;

import SocialNetwork.SocialNetwork.util.Enum.friendStatus;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.time.Instant;

@Entity
@Table(name = "friend_requests",
        uniqueConstraints = {
                @UniqueConstraint(name = "uk_friend_request_pair", columnNames = {"requester_id","addressee_id"})
        },
        indexes = {
                @Index(name = "idx_friend_requests_addressee", columnList = "addressee_id"),
                @Index(name = "idx_friend_requests_requester", columnList = "requester_id")
        })
@Getter @Setter
public class FriendRequest {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    // người gửi
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "requester_id", nullable = false)
    private User requester;

    // người nhận
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "addressee_id", nullable = false)
    private User addressee;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false, length = 20)
    private friendStatus status;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt;

    @PrePersist
    protected void onCreate() {
        this.createdAt = Instant.now();
        if (this.status == null) this.status = friendStatus.pending;
    }
}
