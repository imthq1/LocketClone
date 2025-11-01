import 'package:flutter/material.dart';
// import 'package:locket_clone/screens/feed/widgets/activity_info.dart';
import 'package:locket_clone/screens/feed/widgets/post_card.dart';
import 'package:locket_clone/screens/feed/widgets/post_info.dart';
import 'package:locket_clone/services/data/models/post_dto.dart';

class MyFeedPostPage extends StatelessWidget {
  final PostDTO post;
  const MyFeedPostPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ảnh + caption
          PostCard(post: post),

          const SizedBox(height: 20),

          // Thông tin thời gian
          PostInfo(post: post),

          // const ActivityInfo(),
          const SizedBox(height: 250),
        ],
      ),
    );
  }
}
