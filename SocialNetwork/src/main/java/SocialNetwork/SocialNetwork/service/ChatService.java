package SocialNetwork.SocialNetwork.service;

import SocialNetwork.SocialNetwork.domain.Conversation;
import SocialNetwork.SocialNetwork.domain.Message;
import SocialNetwork.SocialNetwork.domain.Response.MessageResponseDTO;
import SocialNetwork.SocialNetwork.domain.User;
import SocialNetwork.SocialNetwork.repository.ConversationRepository;
import SocialNetwork.SocialNetwork.repository.MessageRepository;
import SocialNetwork.SocialNetwork.repository.UserRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ChatService {

    private final ConversationRepository conversationRepo;
    private final MessageRepository messageRepo;
    private final UserRepository userRepo;
    @Transactional
    public MessageResponseDTO createMessage(Long conversationId, Long senderId, String content, String image) {
        Conversation conv = conversationRepo.findById(conversationId)
                .orElseThrow(() -> new RuntimeException("Conversation not found"));

        User sender = userRepo.findById(senderId)
                .orElseThrow(() -> new RuntimeException("Sender not found"));

        if (!sender.getId().equals(conv.getUser1().getId()) &&
                !sender.getId().equals(conv.getUser2().getId())) {
            throw new RuntimeException("Sender is not part of this conversation");
        }

        Message msg = Message.builder()
                .conversation(conv)
                .sender(sender)
                .content(content)
                .image(image)
                .read(false)
                .createdAt(Instant.now())
                .build();

        Message saved = messageRepo.save(msg);
        conv.setUpdatedAt(Instant.now());
        conversationRepo.save(conv);

        return mapToDTO(saved);
    }
    public Long findPeerId(Long conversationId, Long currentUserId) {
        Long peerId = conversationRepo.findPeerId(conversationId, currentUserId);
        if (peerId == null) {
            throw new RuntimeException("User is not part of this conversation or conversation not found");
        }
        return peerId;
    }
    private MessageResponseDTO mapToDTO(Message msg) {
        return MessageResponseDTO.builder()
                .id(msg.getId())
                .conversationId(msg.getConversation().getId())
                .senderId(msg.getSender().getId())
                .senderEmail(msg.getSender().getEmail())
                .content(msg.getContent())
                .image(msg.getImage())
                .read(msg.isRead())
                .createdAt(msg.getCreatedAt())
                .build();
    }
    @Transactional
    public Conversation getOrCreateConversation(User a, User b) {
        return conversationRepo.findByUserPair(a.getId(), b.getId())
                .orElseGet(() -> {
                    Conversation c = Conversation.builder()
                            .user1(a.getId() < b.getId() ? a : b)
                            .user2(a.getId() < b.getId() ? b : a)
                            .build();
                    return conversationRepo.save(c);
                });
    }
    public List<Conversation> getConversations(Long userId) {
        return this.conversationRepo.findAllForUser(userId);
    }
    // Gửi tin nhắn
    @Transactional
    public Message sendMessage(Long conversationId, User sender, String content, String image) {
        Conversation c = conversationRepo.findById(conversationId)
                .orElseThrow(() -> new IllegalArgumentException("Conversation not found"));

        Message m = Message.builder()
                .conversation(c)
                .sender(sender)
                .content(content)
                .image(image)
                .build();

        Message saved = messageRepo.save(m);

        c.setUpdatedAt(saved.getCreatedAt());

        return saved;
    }

    public Page<Message> getMessages(Long conversationId, int page, int size) {
        return messageRepo.findByConversation(conversationId, PageRequest.of(page, size));
    }

    @Transactional
    public int markAllRead(Long conversationId, Long me) {
        return messageRepo.markAllRead(conversationId, me);
    }
}