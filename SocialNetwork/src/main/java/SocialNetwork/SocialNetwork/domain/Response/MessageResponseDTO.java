package SocialNetwork.SocialNetwork.domain.Response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class MessageResponseDTO {
    private Long id;
    private Long conversationId;
    private Long senderId;
    private String senderEmail;
    private String content;
    private String image;
    private boolean read;
    private Instant createdAt;
}