package SocialNetwork.SocialNetwork.service;

import SocialNetwork.SocialNetwork.domain.Conversation;
import SocialNetwork.SocialNetwork.domain.FriendRequest;
import SocialNetwork.SocialNetwork.domain.Message;
import SocialNetwork.SocialNetwork.domain.Request.FriendRequestItemDTO;
import SocialNetwork.SocialNetwork.domain.Response.FriendRequestBySender;
import SocialNetwork.SocialNetwork.domain.Response.UserDTO;
import SocialNetwork.SocialNetwork.domain.User;
import SocialNetwork.SocialNetwork.repository.ConversationRepository;
import SocialNetwork.SocialNetwork.repository.FriendRequestRepository;
import SocialNetwork.SocialNetwork.repository.MessageRepository;
import SocialNetwork.SocialNetwork.repository.UserRepository;
import SocialNetwork.SocialNetwork.util.Enum.friendStatus;
import SocialNetwork.SocialNetwork.util.SecurityUtil;
import jakarta.transaction.Transactional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.security.oauth2.jwt.Jwt;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

@Service
public class FriendService {
    private final FriendRequestRepository friendRequestRepository;
    private final UserRepository userRepository;
    private final UserService userService;
    private final SecurityUtil securityUtil;
    private final ChatService chatService;
    private final ConversationRepository conversationRepository;
    private final MessageRepository messageRepository;

    public FriendService(FriendRequestRepository friendRequestRepository,
                         UserRepository userRepository, UserService userService, SecurityUtil securityUtil,
                         ChatService chatService, ConversationRepository conversationRepository, MessageRepository messageRepository) {
        this.friendRequestRepository = friendRequestRepository;
        this.userRepository = userRepository;
        this.userService = userService;
        this.securityUtil = securityUtil;
        this.chatService = chatService;
        this.conversationRepository = conversationRepository;
        this.messageRepository = messageRepository;
    }
    public void sendRequestFr(String email, long addressee_id ) {
        User  userSendRequestFr = userRepository.findByEmail(email);
        User  userAddressee = userRepository.findById(addressee_id).get();
        FriendRequest friendRequest = new FriendRequest();
        friendRequest.setRequester(userSendRequestFr);
        friendRequest.setAddressee(userAddressee);
        friendRequest.setStatus(friendStatus.pending);
        friendRequestRepository.save(friendRequest);
    }
    public UserDTO searchUser(String email) {
        User user = userRepository.findByEmail(email);
        UserDTO userDTO = new UserDTO();
        userDTO.setId(user.getId());
        userDTO.setEmail(user.getEmail());
        userDTO.setImage(user.getImageUrl());
        userDTO.setFullname(user.getFullname());
        userDTO.setAddress(user.getAddress());
        return userDTO;
    }
    public boolean existByAdresseeIdAndSender(long adressee_id, String emailSender) {
        User userSendRequestFr = userRepository.findByEmail(emailSender);
        return this.friendRequestRepository.existsByAddressee_IdAndRequester_Id(adressee_id,userSendRequestFr.getId());
    }
    public void sendRequestByQr(String email, String token) {
        User  userSendRequestFr = userRepository.findByEmail(email);
        Jwt jwt=this.securityUtil.checkValidRefreshToken(token);

        String emailAddressee= jwt.getSubject();


        FriendRequest friendRequest = new FriendRequest();
        friendRequest.setRequester(userSendRequestFr);
        friendRequest.setAddressee(userRepository.findByEmail(emailAddressee));
        friendRequest.setStatus(friendStatus.pending);
        friendRequestRepository.save(friendRequest);
    }
    public List<UserDTO> getListFr() {
        String email = SecurityUtil.getCurrentUserLogin().get();
        User me = this.userService.getUserByEmail(email);

        List<User> friends = this.friendRequestRepository.findFriendsOf(email);

        return friends.stream().map(friend -> {
            UserDTO dto = new UserDTO();
            dto.setId(friend.getId());
            dto.setEmail(friend.getEmail());
            dto.setFullname(friend.getFullname());
            dto.setImage(friend.getImageUrl());
            dto.setAddress(friend.getAddress());

            Optional<Conversation> convOpt = conversationRepository.findConversationBetween(me.getId(), friend.getId());

            if (convOpt.isPresent()) {
                Conversation conv = convOpt.get();

                List<Message> lastMsgList = messageRepository.findLastMessage(conv.getId(), PageRequest.of(0, 1));
                if (!lastMsgList.isEmpty()) {
                    Message last = lastMsgList.get(0);
                    UserDTO.LastMessageDTO lastMsgDTO = new UserDTO.LastMessageDTO();
                    lastMsgDTO.setContent(last.getContent());
                    lastMsgDTO.setCreatedAt(last.getCreatedAt());
                    lastMsgDTO.setSenderId(last.getSender().getId());
                    dto.setLastMessage(lastMsgDTO);
                } else {
                    UserDTO.LastMessageDTO empty = new UserDTO.LastMessageDTO();
                    empty.setContent("Hãy gửi lời chào 👋");
                    dto.setLastMessage(empty);
                }
            } else {
                UserDTO.LastMessageDTO empty = new UserDTO.LastMessageDTO();
                empty.setContent("Hãy gửi lời chào 👋");
                dto.setLastMessage(empty);
            }

            return dto;
        }).toList();
    }

    @Transactional()
    public Page<FriendRequestBySender> listFriendBySender(String senderEmail, friendStatus status, Pageable pageable) {
        User me = userService.getUserByEmail(senderEmail);
        if (me == null) throw new IllegalStateException("Current user not found");

        Page<FriendRequest> page = friendRequestRepository
                .findByRequester_IdAndStatus(me.getId(), status, pageable);

        return page.map(fr -> FriendRequestBySender.builder()
                .requestId(fr.getId())
                .targetUserId(fr.getAddressee().getId())
                .targetEmail(fr.getAddressee().getEmail())
                .targetFullname(fr.getAddressee().getFullname())
                .targetAvatar(fr.getAddressee().getImageUrl())
                .createdAt(fr.getCreatedAt())
                .status(fr.getStatus().name())
                .build());
    }
    public void acceptRequestBySender(String senderEmail) {
        String emailCurrent=SecurityUtil.getCurrentUserLogin().get();
        User userCurrent=userRepository.findByEmail(emailCurrent);
        User userSendRequestFr = userRepository.findByEmail(senderEmail);
        FriendRequest friendRequest = friendRequestRepository.findFirstByAddressee_EmailAndRequester_EmailAndStatusOrderByCreatedAtDesc(
                emailCurrent,
                senderEmail,
                friendStatus.pending);
        friendRequest.setStatus(friendStatus.accepted);
        friendRequestRepository.save(friendRequest);
        this.chatService.getOrCreateConversation(userCurrent,userSendRequestFr);
    }
    public void deleteFrRqById(long id){
        this.friendRequestRepository.deleteById(id);
    }

    @Transactional()
    public List<FriendRequestItemDTO> listReceivedRequestsForCurrentUser() {
        String email = SecurityUtil.getCurrentUserLogin()
                .orElseThrow(() -> new IllegalStateException("User not logged in"));

        User me = userService.getUserByEmail(email);
        if (me == null) {
            throw new IllegalStateException("Current user not found");
        }

        List<FriendRequest> requests = friendRequestRepository
                .findByAddressee_IdAndStatusOrderByCreatedAtDesc(me.getId(), friendStatus.pending);

        return requests.stream().map(fr -> FriendRequestItemDTO.builder()
                .requestId(fr.getId())
                .requesterId(fr.getRequester().getId())
                .requesterEmail(fr.getRequester().getEmail())
                .requesterFullname(fr.getRequester().getFullname())
                .requesterAvatar(fr.getRequester().getImageUrl())
                .createdAt(fr.getCreatedAt())
                .status(fr.getStatus().name())
                .build()
        ).toList();
    }
    public void deleteFriendShip(long userId){
        String email = SecurityUtil.getCurrentUserLogin().get();
        User me = userRepository.findByEmail(email);
        friendRequestRepository.deleteFriendShip(userId, me.getId());
    }
}
