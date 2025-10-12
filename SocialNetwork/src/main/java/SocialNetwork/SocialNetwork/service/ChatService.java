package SocialNetwork.SocialNetwork.service;

import SocialNetwork.SocialNetwork.domain.Conversation;
import SocialNetwork.SocialNetwork.domain.Message;
import SocialNetwork.SocialNetwork.domain.User;
import SocialNetwork.SocialNetwork.repository.ConversationRepository;
import SocialNetwork.SocialNetwork.repository.MessageRepository;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class ChatService {

    private final ConversationRepository conversationRepo;
    private final MessageRepository messageRepo;

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