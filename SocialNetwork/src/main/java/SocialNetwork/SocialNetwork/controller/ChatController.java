package SocialNetwork.SocialNetwork.controller;

import SocialNetwork.SocialNetwork.domain.Conversation;
import SocialNetwork.SocialNetwork.domain.User;
import SocialNetwork.SocialNetwork.repository.UserRepository;
import SocialNetwork.SocialNetwork.service.ChatService;
import SocialNetwork.SocialNetwork.util.ApiMessage;
import SocialNetwork.SocialNetwork.util.SecurityUtil;
import org.apache.coyote.Response;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
public class ChatController {
    private final ChatService chatService;
    private final UserRepository UserRepository;
    public ChatController(ChatService chatService, UserRepository UserRepository) {
        this.chatService = chatService;
        this.UserRepository = UserRepository;
    }
    @GetMapping("/messageConversation")
    @ApiMessage("")
    public ResponseEntity<Conversation> messageConversation(@RequestParam String emailRq) {
        String emailCurrent= SecurityUtil.getCurrentUserLogin().get();
        User userCur=this.UserRepository.findByEmail(emailCurrent);
        User userReq=this.UserRepository.findByEmail(emailRq);
        return ResponseEntity.ok(this.chatService.getOrCreateConversation(userCur,userReq));
    }
}
