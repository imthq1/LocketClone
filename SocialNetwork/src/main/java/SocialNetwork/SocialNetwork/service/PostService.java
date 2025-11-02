package SocialNetwork.SocialNetwork.service;

import SocialNetwork.SocialNetwork.domain.Post;
import SocialNetwork.SocialNetwork.domain.User;
import SocialNetwork.SocialNetwork.repository.PostRepository;
import SocialNetwork.SocialNetwork.util.Enum.friendStatus;
import SocialNetwork.SocialNetwork.util.Enum.visibilityEnum;
import SocialNetwork.SocialNetwork.util.SecurityUtil;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;

@Service
public class PostService {
    private final PostRepository postRepository;
    private final UserService userService;
    private final SecurityUtil securityUtil;

    public PostService(PostRepository postRepository, UserService userService, SecurityUtil securityUtil) {
        this.postRepository = postRepository;
        this.userService = userService;
        this.securityUtil = securityUtil;
    }
    public Post deletePostById(Long postId) {
        return this.postRepository.deletePostById(postId);
    }
    public Post save(Post post) {
        post.setUser(userService.getUserByEmail(SecurityUtil.getCurrentUserLogin().get()));
        return postRepository.save(post);
    }
    public Page<Post> getFeed(int page, int size) {
        String email=SecurityUtil.getCurrentUserLogin().get();
        User user=this.userService.getUserByEmail(email);
        Pageable pageable = PageRequest.of(
                page, size,
                Sort.by(Sort.Direction.DESC, "created_at").and(Sort.by(Sort.Direction.DESC, "id"))
        );
        return postRepository.findFeedForUser(
                user.getId(),
                visibilityEnum.friend,
                visibilityEnum.custom,
                friendStatus.accepted,
                pageable
        );
    }
}
