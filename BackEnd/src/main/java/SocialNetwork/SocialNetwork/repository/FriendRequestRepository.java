package SocialNetwork.SocialNetwork.repository;

import SocialNetwork.SocialNetwork.domain.FriendRequest;
import SocialNetwork.SocialNetwork.domain.User;
import SocialNetwork.SocialNetwork.util.Enum.friendStatus;
import jakarta.transaction.Transactional;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FriendRequestRepository extends JpaRepository<FriendRequest, Long> {
    boolean existsByAddressee_IdAndRequester_Id(Long addresseeId, Long requesterId);
    List<FriendRequest> findByAddressee_IdAndStatusOrderByCreatedAtDesc(
            Long addresseeId,
            friendStatus status
    );
    FriendRequest findFirstByAddressee_EmailAndRequester_EmailAndStatusOrderByCreatedAtDesc(
            String addresseeEmail,
            String requesterEmail,
            friendStatus status
    );
    Page<FriendRequest> findByRequester_IdAndStatus(
            Long requesterId,
            friendStatus status,
            Pageable pageable
    );
    @Query("""
  SELECT u
  FROM User u
  WHERE EXISTS (
    SELECT 1
    FROM FriendRequest fr
    WHERE fr.status = 'accepted'
      AND (
        (fr.requester = u AND fr.addressee.email = :email)
        OR
        (fr.addressee = u AND fr.requester.email = :email)
      )
  )
""")
    List<User> findFriendsOf(@Param("email") String email);

    @Modifying(clearAutomatically = true, flushAutomatically = true)
    @Transactional
    @Query("""
        DELETE FROM FriendRequest fr
        WHERE fr.status = 'accepted'
          AND (
               (fr.requester.id = :userRequesterId AND fr.addressee.id = :userAddresseeId)
            OR (fr.requester.id = :userAddresseeId AND fr.addressee.id = :userRequesterId)
          )
        """)
    void deleteFriendShip(@Param("userRequesterId") long userRequesterId,
                          @Param("userAddresseeId") long userAddresseeId);
}