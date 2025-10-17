package SocialNetwork.SocialNetwork.domain;

import SocialNetwork.SocialNetwork.domain.Response.UserDTO;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MessageSimpleDTO {
    private Long id;
    private String content;
    private String image;
    private boolean read;
    private Instant createdAt;
    private UserSimpleDTO sender;

    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    @Builder
    public static class UserSimpleDTO {
        private Long id;
        private String email;
        private String fullname;
        private String imageUrl;
    }
}