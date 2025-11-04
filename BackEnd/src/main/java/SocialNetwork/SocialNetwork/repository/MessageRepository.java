package SocialNetwork.SocialNetwork.repository;

import SocialNetwork.SocialNetwork.domain.Message;
import org.springframework.data.domain.*;
import org.springframework.data.jpa.repository.*;
import org.springframework.data.repository.query.Param;

import java.util.List;

public interface MessageRepository extends JpaRepository<Message, Long> {

    // Lấy message theo conversation (phân trang, cũ → mới)
    @Query("""
      SELECT m FROM Message m
      WHERE m.conversation.id = :cid
      ORDER BY m.createdAt ASC
    """)
    Page<Message> findByConversation(@Param("cid") Long conversationId, Pageable pageable);

    // Đếm tin chưa đọc của user trong 1 conversation
    @Query("""
      SELECT COUNT(m) FROM Message m
      WHERE m.conversation.id = :cid
        AND m.read = false
        AND m.sender.id <> :me
    """)
    long countUnread(@Param("cid") Long conversationId, @Param("me") Long me);

    // Đánh dấu đã đọc (update bulk)
    @Modifying
    @Query("""
      UPDATE Message m
      SET m.read = true
      WHERE m.conversation.id = :cid
        AND m.sender.id <> :me
        AND m.read = false
    """)
    int markAllRead(@Param("cid") Long conversationId, @Param("me") Long me);
    @Query("""
        SELECT m FROM Message m
        WHERE m.conversation.id = :convId
        ORDER BY m.createdAt DESC, m.id DESC
    """)
    List<Message> findLastMessage(@Param("convId") Long convId, Pageable pageable);
}
