package SocialNetwork.SocialNetwork.domain.Request;



import lombok.Builder;
import lombok.Value;
import java.time.Instant;


@Value
@Builder
public class FriendRequestItemDTO {
    Long requestId;

    Long requesterId;
    String requesterEmail;
    String requesterFullname;
    String requesterAvatar;

    Instant createdAt;
    String status;
}
