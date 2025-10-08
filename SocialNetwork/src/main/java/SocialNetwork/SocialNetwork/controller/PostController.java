package SocialNetwork.SocialNetwork.controller;

import SocialNetwork.SocialNetwork.domain.Post;
import SocialNetwork.SocialNetwork.service.PostService;
import SocialNetwork.SocialNetwork.util.ApiMessage;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/v1")
public class PostController {
    private final PostService postService;
    public PostController(PostService postService) {
        this.postService = postService;
    }
    @PostMapping("/post")
    @ApiMessage("Create a Post")
    public ResponseEntity<Post> createPost(@RequestBody Post post) {
        return ResponseEntity.ok(this.postService.save(post));
    }
}
