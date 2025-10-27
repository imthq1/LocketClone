import 'package:flutter/material.dart';
import 'package:locket_clone/screens/feed/widgets/my_feed_post_page.dart';
import 'package:locket_clone/services/data/models/post_dto.dart'; // Dùng PostDTO

// Dữ liệu giả cho mục đích hiển thị
final PostDTO mockPost = PostDTO(
  id: 1,
  caption: 'caption 👋',
  image: 'locket/fnlvn1l0f8w97j2tewqw', // Đường dẫn ảnh mẫu (từ file bạn gửi)
  visibility: 'friend',
  createdAt: DateTime.now(),
  authorFullname: 'Bạn',
);

class MyFeedView extends StatelessWidget {
  const MyFeedView({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: Thay thế bằng Consumer<PostController> để lấy dữ liệu thật
    final List<PostDTO> posts = [mockPost, mockPost, mockPost]; // Giả lập 3 bài

    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return MyFeedPostPage(post: posts[index]);
      },
    );
  }
}
