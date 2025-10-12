// PostDTO.java
package SocialNetwork.SocialNetwork.domain.Response;

import SocialNetwork.SocialNetwork.domain.Post;
import lombok.*;

import java.time.Instant;

@Getter @Setter @NoArgsConstructor @AllArgsConstructor
public class PostDTO {
    private Long id;
    private String caption;
    private String image;
    private Instant createdAt;
    private Long authorId;
    private String authorEmail;
    private String authorFullname;
    private String visibility;

    public static PostDTO fromEntity(Post p) {
        PostDTO dto = new PostDTO();
        dto.setId(p.getId());
        dto.setCaption(p.getCaption());
        dto.setImage(p.getImage());
        dto.setCreatedAt(p.getCreated_at());
        dto.setAuthorId(p.getUser().getId());
        dto.setAuthorEmail(p.getUser().getEmail());
        dto.setAuthorFullname(p.getUser().getFullname());
        dto.setVisibility(p.getVisibility().name());
        return dto;
    }
}
