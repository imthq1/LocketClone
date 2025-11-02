package SocialNetwork.SocialNetwork.domain.Response;

import lombok.*;

import java.time.Instant;

// FriendRequestItemDTO.java
@Value
@Builder
@AllArgsConstructor
@Getter
@Setter
public class FriendRequestBySender {
    Long requestId;

    Long targetUserId;
    String targetEmail;
    String targetFullname;
    String targetAvatar;

    Instant createdAt;
    String status;
}
