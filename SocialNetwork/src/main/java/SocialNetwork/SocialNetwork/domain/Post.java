package SocialNetwork.SocialNetwork.domain;

import SocialNetwork.SocialNetwork.util.Enum.visibilityEnum;
import com.fasterxml.jackson.annotation.JsonBackReference;
import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.Instant;

@Entity
@Table(name = "posts")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class Post {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String caption;
    private String image;
    private Instant created_at;

    @Enumerated(EnumType.STRING)
    private visibilityEnum visibility;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    @JsonBackReference(value = "post_user")
    private User user;

    @PrePersist
    protected void onCreate() {
        this.created_at = Instant.now();
    }
}
