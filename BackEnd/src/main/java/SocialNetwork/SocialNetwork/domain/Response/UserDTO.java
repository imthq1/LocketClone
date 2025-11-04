package SocialNetwork.SocialNetwork.domain.Response;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.Instant;
import java.util.List;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class UserDTO {
    private long id;
    private String email;
    private String fullname;
    private String address;
    private String RoleName;
    private String image;
    private Friend friend;
    private LastMessageDTO lastMessage;
    @Getter
    @Setter
    @AllArgsConstructor
    @NoArgsConstructor
    public static class Friend{
        private long sumUser;
        private List<UserDTO> friends;
    }
    @Getter
    @Setter
    @AllArgsConstructor
    @NoArgsConstructor
    public static class LastMessageDTO {
        private String content;
        private Instant createdAt;
        private Long senderId;

    }


}