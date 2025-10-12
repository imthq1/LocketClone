package SocialNetwork.SocialNetwork.config;

import SocialNetwork.SocialNetwork.domain.User;
import SocialNetwork.SocialNetwork.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.event.EventListener;
import org.springframework.messaging.simp.SimpMessageSendingOperations;
import org.springframework.messaging.simp.stomp.StompHeaderAccessor;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.messaging.SessionConnectedEvent;
import org.springframework.web.socket.messaging.SessionDisconnectEvent;

import java.sql.Time;
import java.time.LocalDateTime;
import java.time.LocalTime;


@Component
public class WebSocketEventListener {
    private final UserRepository userRepository;
    private static final Logger logger = LoggerFactory.getLogger(WebSocketEventListener.class);

    public WebSocketEventListener(UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    @Autowired
    private SimpMessageSendingOperations messagingTemplate;

    @EventListener
    public void handleWebSocketConnectListener(SessionConnectedEvent event) {
        logger.info("Received a new web socket connection");
    }

//    @EventListener
//    public void handleWebSocketDisconnectListener(SessionDisconnectEvent event) {
//        StompHeaderAccessor headerAccessor = StompHeaderAccessor.wrap(event.getMessage());
//
//        String email = (String) headerAccessor.getSessionAttributes().get("email");
//        User user = userRepository.findByEmail(email);
//        if(user != null) {
//            logger.info("User Disconnected : " + user);
//
//            Message chatMessage = new Message();
//            chatMessage.setSender(user.getUsername());
//            chatMessage.setText(user.getUsername() + " đã rời khỏi phòng chat.");
//            chatMessage.setTime(LocalDateTime.now());
//            messagingTemplate.convertAndSend("/topic/userLeft", chatMessage);
//
//        }
//    }
}
