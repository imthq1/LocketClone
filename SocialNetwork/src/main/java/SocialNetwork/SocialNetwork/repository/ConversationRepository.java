package SocialNetwork.SocialNetwork.repository;


import SocialNetwork.SocialNetwork.domain.Conversation;
import org.springframework.data.jpa.repository.*;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface ConversationRepository extends JpaRepository<Conversation, Long> {

    // Tìm cuộc trò chuyện 1-1 (bất kể thứ tự)
    @Query("""
      SELECT c FROM Conversation c
      WHERE (c.user1.id = :a AND c.user2.id = :b)
         OR (c.user1.id = :b AND c.user2.id = :a)
    """)
    Optional<Conversation> findByUserPair(@Param("a") Long a, @Param("b") Long b);

    // Danh sách hội thoại của user (mới nhất trước)
    @Query("""
      SELECT c FROM Conversation c
      WHERE c.user1.id = :me OR c.user2.id = :me
      ORDER BY c.updatedAt DESC
    """)
    List<Conversation> findAllForUser(@Param("me") Long me);

}