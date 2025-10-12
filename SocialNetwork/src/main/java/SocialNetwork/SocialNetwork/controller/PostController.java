package SocialNetwork.SocialNetwork.controller;

import SocialNetwork.SocialNetwork.domain.Post;
import SocialNetwork.SocialNetwork.domain.Response.PostDTO;
import SocialNetwork.SocialNetwork.service.PostService;
import SocialNetwork.SocialNetwork.service.UserService;
import SocialNetwork.SocialNetwork.util.ApiMessage;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.domain.Page;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/v1")
public class PostController {
    private final PostService postService;
    private final UserService userService;

    public PostController(PostService postService, UserService userService) {
        this.postService = postService;
        this.userService = userService;
    }
    @PostMapping("/post")
    @ApiMessage("Create a Post")
    public ResponseEntity<Post> createPost(@RequestBody Post post) {
        return ResponseEntity.ok(this.postService.save(post));
    }
    @GetMapping("/feed")
    public ResponseEntity<Map<String, Object>> getFeed(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size
    ) {
        Page<Post> result = postService.getFeed( page, size);

        List<PostDTO> items = result.getContent().stream().map(PostDTO::fromEntity).toList();

        Map<String, Object> body = new HashMap<>();
        body.put("page", result.getNumber());
        body.put("size", result.getSize());
        body.put("totalPages", result.getTotalPages());
        body.put("totalElements", result.getTotalElements());
        body.put("data", items);

        return ResponseEntity.ok(body);
    }
}
