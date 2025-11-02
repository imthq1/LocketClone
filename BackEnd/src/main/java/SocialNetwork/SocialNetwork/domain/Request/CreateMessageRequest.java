package SocialNetwork.SocialNetwork.domain.Request;

import lombok.*;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class CreateMessageRequest {
    private Long conversationId;
    private Long senderId;
    private String content;
    private String image;
}