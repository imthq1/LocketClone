package SocialNetwork.SocialNetwork.domain.Response;

import SocialNetwork.SocialNetwork.domain.MessageSimpleDTO;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.Instant;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ConversationDTO {
    private Long id;
    private Instant createdAt;
    private Instant updatedAt;
    private MessageSimpleDTO.UserSimpleDTO user1;
    private MessageSimpleDTO.UserSimpleDTO user2;
    private List<MessageSimpleDTO> messages;
}