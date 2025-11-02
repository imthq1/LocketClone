package SocialNetwork.SocialNetwork.domain;
import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "post_recipients",
        uniqueConstraints = @UniqueConstraint(columnNames = {"post_id","user_id"}),
        indexes = @Index(name = "idx_post_recipients_user", columnList = "user_id"))
@Getter @Setter @NoArgsConstructor @AllArgsConstructor
public class PostRecipient {
    @EmbeddedId
    private PostRecipientId id;

    @MapsId("postId")
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "post_id")
    private Post post;

    @MapsId("userId")
    @ManyToOne(fetch = FetchType.LAZY, optional = false)
    @JoinColumn(name = "user_id")
    private User user;
}

