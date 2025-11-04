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
    @Query("""
        select case
            when c.user1.id = :currentUserId then c.user2.id
            else c.user1.id
        end
        from Conversation c
        where c.id = :conversationId
          and (:currentUserId = c.user1.id or :currentUserId = c.user2.id)
        """)
    Long findPeerId(@Param("conversationId") Long conversationId,
                    @Param("currentUserId") Long currentUserId);

        @Query("""
        SELECT c
        FROM Conversation c
        WHERE (c.user1.id = :meId AND c.user2.id = :friendId)
           OR (c.user2.id = :meId AND c.user1.id = :friendId)
    """)
        Optional<Conversation> findConversationBetween(
                @Param("meId") Long meId,
                @Param("friendId") Long friendId
        );

}