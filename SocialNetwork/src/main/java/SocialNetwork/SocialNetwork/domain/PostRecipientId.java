package SocialNetwork.SocialNetwork.domain;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

// PostRecipientId.java
@Embeddable
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class PostRecipientId implements java.io.Serializable {
    @Column(name = "post_id")
    private Long postId;

    @Column(name = "user_id")
    private Long userId;
}
