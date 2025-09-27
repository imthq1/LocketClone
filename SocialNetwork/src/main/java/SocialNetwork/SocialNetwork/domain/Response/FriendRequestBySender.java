package SocialNetwork.SocialNetwork.domain.Response;

import lombok.Builder;
import lombok.Value;

import java.time.Instant;

// FriendRequestItemDTO.java
@Value
@Builder
public class FriendRequestBySender {
    Long requestId;

    Long targetUserId;
    String targetEmail;
    String targetFullname;
    String targetAvatar;

    Instant createdAt;
    String status;
}
