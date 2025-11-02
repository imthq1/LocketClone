import 'package:flutter/material.dart';
import 'package:locket_clone/services/data/models/post_dto.dart';
import 'package:locket_clone/theme/app_colors.dart';
import 'package:locket_clone/screens/friends/utils/initials.dart';
import 'package:locket_clone/shared/cloudinary_helper.dart';

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
    final authorName = post.authorFullname ?? post.authorEmail ?? 'User';
    final authorAvatar = post.authorAvatar;
    final bool hasImage = authorAvatar != null && authorAvatar.isNotEmpty;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: AppColors.fieldBackground,
          backgroundImage: hasImage
              ? NetworkImage(buildCloudinaryUrl(authorAvatar))
              : null,
          child: hasImage
              ? null
              : Text(
                  initialsFrom(authorName),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
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
