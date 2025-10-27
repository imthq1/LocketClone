import 'package:flutter/material.dart';
import 'package:locket_clone/screens/feed/widgets/friend_feed_post_page.dart';
import 'package:locket_clone/services/data/models/post_dto.dart';

// Dữ liệu giả cho mục đích hiển thị (dựa trên image_fdefe8.jpg)
final PostDTO mockFriendPost = PostDTO(
  id: 2,
  caption: '', // Ảnh này không có caption
  image: 'locket/fnlvn1l0f8w97j2tewqw', // Ảnh phòng gym
  visibility: 'friend',
  createdAt: DateTime.now().subtract(const Duration(days: 5)),
  authorFullname: 'T', // Tên tác giả
);

class FriendFeedView extends StatelessWidget {
  const FriendFeedView({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Thay thế bằng Consumer<PostController> để lấy dữ liệu feed bạn bè
    final List<PostDTO> posts = [
      mockFriendPost,
      mockFriendPost,
      mockFriendPost,
    ];

    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return FriendFeedPostPage(post: posts[index]);
      },
    );
  }
}
