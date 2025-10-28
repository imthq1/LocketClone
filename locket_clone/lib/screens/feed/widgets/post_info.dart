import 'package:flutter/material.dart';
import 'package:locket_clone/services/data/models/post_dto.dart';
import 'package:locket_clone/theme/app_colors.dart';

class PostInfo extends StatelessWidget {
  final PostDTO post;
  const PostInfo({super.key, required this.post});

  String _formatTimestamp(DateTime? time) {
    if (time == null) return '';

    final now = DateTime.now();
    final difference = now.toUtc().difference(time.toUtc());

    if (difference.inSeconds < 60) {
      return 'Vừa xong';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      final weeks = (difference.inDays / 7).floor();
      return '${weeks}w';
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeAgo = _formatTimestamp(post.createdAt);

    final authorName = post.authorFullname ?? 'T';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: AppColors.fieldBackground,
          child: Icon(Icons.person, size: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 8),
        Text(
          authorName,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          timeAgo,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 15),
        ),
      ],
    );
  }
}
