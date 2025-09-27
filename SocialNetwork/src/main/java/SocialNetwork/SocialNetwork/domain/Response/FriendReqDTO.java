package SocialNetwork.SocialNetwork.domain.Response;

import SocialNetwork.SocialNetwork.util.Enum.friendStatus;
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
public class FriendReqDTO {
    public String nameRequester;;
    public String nameAddressee;
    public Instant dateRequested;
    @Enumerated
    public friendStatus status;
}
