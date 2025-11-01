package SocialNetwork.SocialNetwork.service;

import SocialNetwork.SocialNetwork.domain.FriendRequest;
import SocialNetwork.SocialNetwork.domain.Response.UserDTO;
import SocialNetwork.SocialNetwork.domain.User;
import SocialNetwork.SocialNetwork.repository.FriendRequestRepository;
import SocialNetwork.SocialNetwork.repository.UserRepository;
import jakarta.transaction.Transactional;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class UserService {
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;
    private final FriendRequestRepository FriendRequestRepository;
    public UserService(UserRepository userRepository, PasswordEncoder passwordEncoder,
                       FriendRequestRepository friendRequestRepository) {
        this.userRepository = userRepository;
        this.passwordEncoder = passwordEncoder;
        this.FriendRequestRepository = friendRequestRepository;
    }
    public User save(User user) {
       return userRepository.save(user);
    }
    public User findByEmail(String email) {
        return userRepository.findByEmail(email);
    }
    public User getUserByEmail(String email) {
        return userRepository.findByEmail(email);
    }
    public List<User> findAcceptedByRequesterEmail(String email)
    {
        return this.FriendRequestRepository.findFriendsOf(email);
    }
    @Transactional
    public UserDTO CreateUser(User user) {
        user.setPassword(this.passwordEncoder.encode(user.getPassword()));
        User UserDTO= this.userRepository.save(user);
        UserDTO userDTO = new UserDTO();
        userDTO.setId(UserDTO.getId());
        userDTO.setEmail(UserDTO.getEmail());
        userDTO.setAddress(UserDTO.getAddress());
        userDTO.setFullname(UserDTO.getFullname());

        return userDTO;
    }

}
