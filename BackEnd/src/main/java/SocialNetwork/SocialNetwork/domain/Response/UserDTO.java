package SocialNetwork.SocialNetwork.domain.Response;

import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

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
    @Getter
    @Setter
    @AllArgsConstructor
    @NoArgsConstructor
    public static class Friend{
        private long sumUser;
        private List<UserDTO> friends;
    }

}