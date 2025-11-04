package SocialNetwork.SocialNetwork.domain.Response;
import SocialNetwork.SocialNetwork.util.Enum.visibilityEnum;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import lombok.AllArgsConstructor;
import lombok.Getter;

import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.Instant;


@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class PostFeedDTO {
    private Long id;
    private String caption;
    private String image;
    private Instant createdAt;
    @Enumerated(EnumType.STRING)
    private visibilityEnum visibility;

    private Long authorId;
    private String authorEmail;
    private String authorFullname;
    private String authorAvatar;


}