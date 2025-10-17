package SocialNetwork.SocialNetwork.controller;

import SocialNetwork.SocialNetwork.domain.Conversation;
import SocialNetwork.SocialNetwork.domain.Message;
import SocialNetwork.SocialNetwork.domain.Request.CreateMessageRequest;
import SocialNetwork.SocialNetwork.domain.Response.ConversationDTO;
import SocialNetwork.SocialNetwork.domain.Response.MessageResponseDTO;
import SocialNetwork.SocialNetwork.domain.User;
import SocialNetwork.SocialNetwork.repository.UserRepository;
import SocialNetwork.SocialNetwork.service.ChatService;
import SocialNetwork.SocialNetwork.util.ApiMessage;
import SocialNetwork.SocialNetwork.util.SecurityUtil;
import SocialNetwork.SocialNetwork.util.mapper.ConversationMapper;
import org.apache.coyote.Response;
import org.springframework.http.ResponseEntity;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.List;

@RestController
@RequestMapping("/api/v1")
public class ChatController {
    private final ChatService chatService;
    private final UserRepository UserRepository;
    private final SimpMessagingTemplate messagingTemplate;
    public ChatController(ChatService chatService, UserRepository UserRepository, SimpMessagingTemplate messagingTemplate) {
        this.chatService = chatService;
        this.UserRepository = UserRepository;
        this.messagingTemplate = messagingTemplate;
    }
    @GetMapping("/messageConversation")
    @ApiMessage("Get History Chat")
    public ResponseEntity<ConversationDTO> messageConversation(@RequestParam String emailRq) {
        String emailCurrent = SecurityUtil.getCurrentUserLogin().orElseThrow();
        User userCur = this.UserRepository.findByEmail(emailCurrent);
        User userReq = this.UserRepository.findByEmail(emailRq);
        Conversation conv = this.chatService.getOrCreateConversation(userCur, userReq);

        return ResponseEntity.ok(ConversationMapper.toDTO(conv));
    }
    @PostMapping("/sendMessage")
    public ResponseEntity<MessageResponseDTO> createMessage(@RequestBody CreateMessageRequest req) {
        MessageResponseDTO dto = chatService.createMessage(
                req.getConversationId(),
                req.getSenderId(),
                req.getContent(),
                req.getImage()
        );
        return ResponseEntity.ok(dto);
    }
    @MessageMapping("/conversations/{conversationId}/send")
    public void sendMessage(@DestinationVariable Long conversationId,
                            CreateMessageRequest req) {
        MessageResponseDTO saved = chatService.createMessage(
                conversationId,
                req.getSenderId(),
                req.getContent(),
                req.getImage()
        );

        messagingTemplate.convertAndSend("/topic/conversations." + conversationId, saved);

//        // (tuỳ chọn) đẩy badge/unread riêng cho người nhận
//        Long peerId = chatService.findPeerId(conversationId, currentUserId);
//        messagingTemplate.convertAndSendToUser(String.valueOf(peerId),
//                "/queue/unread",
//                new UnreadEvent(conversationId, saved.getId()));
    }

//    /**
//     * Client SEND tới: /app/conversations/{conversationId}/typing
//     * Server BROADCAST tới: /user/{peerId}/queue/typing
//     */
//    @MessageMapping("/conversations/{conversationId}/typing")
//    public void typing(@DestinationVariable Long conversationId,
//                       TypingReq req,
//                       Principal principal) {
//        Long currentUserId = Long.valueOf(principal.getName());
//        // Validate membership
//        chatService.ensureParticipant(conversationId, currentUserId);
//
//        Long peerId = chatService.findPeerId(conversationId, currentUserId);
//        messagingTemplate.convertAndSendToUser(String.valueOf(peerId),
//                "/queue/typing",
//                new TypingEvent(conversationId, currentUserId, req.isTyping()));
//    }
//
//    /**
//     * Client SEND tới: /app/conversations/{conversationId}/read
//     * Server BROADCAST tới: /topic/conversations.{conversationId}
//     */
//    @MessageMapping("/conversations/{conversationId}/read")
//    public void markRead(@DestinationVariable Long conversationId,
//                         ReadReq req,
//                         Principal principal) {
//        Long currentUserId = Long.valueOf(principal.getName());
//        chatService.markRead(conversationId, currentUserId, req.getMessageId());
//
//        // Broadcast sự kiện đã đọc cho cả 2 bên (để cập nhật UI)
//        messagingTemplate.convertAndSend("/topic/conversations." + conversationId,
//                new ReadEvent(conversationId, req.getMessageId(), currentUserId));
//    }

//    @GetMapping("/conversation")
//    @ApiMessage("")
//    public ResponseEntity<List<Conversation>> getConversation(@RequestParam Long id) {
//        return ResponseEntity.ok(this.chatService.getConversations(id));
//    }
}
