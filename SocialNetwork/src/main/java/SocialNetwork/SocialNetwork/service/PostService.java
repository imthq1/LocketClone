package SocialNetwork.SocialNetwork.service;

import SocialNetwork.SocialNetwork.domain.Post;
import SocialNetwork.SocialNetwork.repository.PostRepository;
import SocialNetwork.SocialNetwork.util.SecurityUtil;
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
    public Post save(Post post) {
        post.setUser(userService.getUserByEmail(SecurityUtil.getCurrentUserLogin().get()));
        return postRepository.save(post);
    }
}
