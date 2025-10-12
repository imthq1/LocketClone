package SocialNetwork.SocialNetwork.domain;

import com.fasterxml.jackson.annotation.JsonBackReference;
import com.fasterxml.jackson.annotation.JsonManagedReference;
import jakarta.persistence.*;
import lombok.*;

import java.time.Instant;
import java.util.List;

@Entity
@Table(
        name = "conversations",
        uniqueConstraints = {
                @UniqueConstraint(name = "uq_conversation_pair", columnNames = {"user1_id", "user2_id"})
        },
        indexes = {
                @Index(name = "idx_conversations_user1", columnList = "user1_id"),
                @Index(name = "idx_conversations_user2", columnList = "user2_id"),
                @Index(name = "idx_conversations_updated", columnList = "updated_at DESC")
        }
)
@Getter @Setter
@NoArgsConstructor @AllArgsConstructor @Builder
public class Conversation {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user1_id", nullable = false)
    @JsonBackReference("conv_user1")
    private User user1;

    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user2_id", nullable = false)
    @JsonBackReference("conv_user2")
    private User user2;

    @Column(name = "created_at", nullable = false, updatable = false)
    private Instant createdAt;

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt;

    @OneToMany(mappedBy = "conversation", cascade = CascadeType.ALL, orphanRemoval = true)
    @OrderBy("createdAt ASC")
    @JsonManagedReference("conv_messages")
    private List<Message> messages;

    @PrePersist
    protected void onCreate() {
        this.createdAt = Instant.now();
        this.updatedAt = this.createdAt;

        // Quy ước user1_id < user2_id để unique constraint hoạt động ổn
        if (user1 != null && user2 != null && user1.getId() != null && user2.getId() != null) {
            if (user1.getId() > user2.getId()) {
                User tmp = user1; user1 = user2; user2 = tmp;
            }
        }
    }

    @PreUpdate
    protected void onUpdate() {
        this.updatedAt = Instant.now();
    }
}