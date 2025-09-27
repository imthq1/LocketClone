package SocialNetwork.SocialNetwork.repository;

import SocialNetwork.SocialNetwork.domain.FriendRequest;
import SocialNetwork.SocialNetwork.util.Enum.friendStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface FriendRequestRepository extends JpaRepository<FriendRequest, Long> {
    boolean existsByAddressee_IdAndRequester_Id(Long addresseeId, Long requesterId);
    List<FriendRequest> findByAddressee_IdAndStatusOrderByCreatedAtDesc(
            Long addresseeId,
            friendStatus status
    );
    Page<FriendRequest> findByRequester_IdAndStatus(
            Long requesterId,
            friendStatus status,
            Pageable pageable
    );
}

