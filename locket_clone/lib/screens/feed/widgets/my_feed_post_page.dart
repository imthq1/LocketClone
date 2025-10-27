import 'package:flutter/material.dart';
import 'package:locket_clone/screens/feed/widgets/activity_info.dart';
import 'package:locket_clone/screens/feed/widgets/post_card.dart';
import 'package:locket_clone/screens/feed/widgets/post_info.dart';
import 'package:locket_clone/services/data/models/post_dto.dart';

class MyFeedPostPage extends StatelessWidget {
  final PostDTO post;
  const MyFeedPostPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Container full-screen cho mỗi trang
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Thẻ ảnh (1:1 + caption)
          PostCard(post: post),

          const SizedBox(height: 16),

          // Thông tin ("Bạn | Vừa xong")
          PostInfo(post: post),

          const SizedBox(height: 24),

          // Thông tin ("Chưa có hoạt động nào")
          const ActivityInfo(),

          // Đệm một khoảng trống ở dưới cùng để BottomBar
          // không che mất nội dung quan trọng
          const SizedBox(height: 120),
        ],
      ),
    );
  }
}