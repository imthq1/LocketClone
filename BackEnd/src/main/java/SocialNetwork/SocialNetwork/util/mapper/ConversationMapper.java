package SocialNetwork.SocialNetwork.util.mapper;


import SocialNetwork.SocialNetwork.domain.Conversation;
import SocialNetwork.SocialNetwork.domain.Message;
import SocialNetwork.SocialNetwork.domain.MessageSimpleDTO;
import SocialNetwork.SocialNetwork.domain.Response.ConversationDTO;
import SocialNetwork.SocialNetwork.domain.User;
import java.util.List;
import java.util.stream.Collectors;

public class ConversationMapper {

    public static ConversationDTO toDTO(Conversation entity) {
        if (entity == null) return null;

        return ConversationDTO.builder()
                .id(entity.getId())
                .createdAt(entity.getCreatedAt())
                .updatedAt(entity.getUpdatedAt())
                .user1(toUserSimpleDTO(entity.getUser1()))
                .user2(toUserSimpleDTO(entity.getUser2()))
                .messages(toMessageDTOList(entity.getMessages()))
                .build();
    }

    private static List<MessageSimpleDTO> toMessageDTOList(List<Message> messages) {
        if (messages == null) return List.of();
        return messages.stream()
                .map(ConversationMapper::toMessageDTO)
                .collect(Collectors.toList());
    }

    private static MessageSimpleDTO toMessageDTO(Message m) {
        return MessageSimpleDTO.builder()
                .id(m.getId())
                .content(m.getContent())
                .image(m.getImage())
                .read(m.isRead())
                .createdAt(m.getCreatedAt())
                .sender(toUserSimpleDTO(m.getSender()))
                .build();
    }

    private static MessageSimpleDTO.UserSimpleDTO toUserSimpleDTO(User u) {
        if (u == null) return null;
        return MessageSimpleDTO.UserSimpleDTO.builder()
                .id(u.getId())
                .email(u.getEmail())
                .fullname(u.getFullname())
                .imageUrl(u.getImageUrl())
                .build();
    }
}