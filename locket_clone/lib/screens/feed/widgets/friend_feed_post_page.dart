import 'package:flutter/material.dart';
import 'package:locket_clone/screens/feed/widgets/friend_post_actions.dart';
import 'package:locket_clone/screens/feed/widgets/post_card.dart';
import 'package:locket_clone/screens/feed/widgets/post_info.dart';
import 'package:locket_clone/services/data/models/post_dto.dart';

class FriendFeedPostPage extends StatelessWidget {
  final PostDTO post;
  const FriendFeedPostPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ảnh + caption
          PostCard(post: post),

          const SizedBox(height: 16),

          // Thông tin thời gian
          PostInfo(post: post),

          const SizedBox(height: 24),

          // Thanh Actions
          const FriendPostActions(),

          const SizedBox(height: 120),
        ],
      ),
    );
  }
}
