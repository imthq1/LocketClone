package SocialNetwork.SocialNetwork.repository;

import SocialNetwork.SocialNetwork.domain.Post;
import SocialNetwork.SocialNetwork.util.Enum.friendStatus;
import SocialNetwork.SocialNetwork.util.Enum.visibilityEnum;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

@Repository
public interface PostRepository extends JpaRepository<Post, Long> {
    @Query("""
    SELECT p
    FROM Post p
    WHERE
      p.user.id = :me
      OR (
        p.visibility = :friends
        AND EXISTS (
          SELECT 1
          FROM FriendRequest fr
          WHERE fr.status = :accepted
            AND (
              (fr.requester.id = :me AND fr.addressee.id = p.user.id)
              OR
              (fr.addressee.id = :me AND fr.requester.id = p.user.id)
            )
        )
      )
      OR (
        p.visibility = :custom
        AND EXISTS (
          SELECT 1
          FROM PostRecipient pr
          WHERE pr.post.id = p.id AND pr.user.id = :me
        )
      )
    """)
    Page<Post> findFeedForUser(
            @Param("me") Long me,
            @Param("friends") visibilityEnum friends,
            @Param("custom") visibilityEnum custom,
            @Param("accepted") friendStatus accepted,
            Pageable pageable
    );
    Post deletePostById(Long id);
}
