import 'package:flutter/material.dart';
import 'package:locket_clone/services/data/models/post_dto.dart';
import 'package:locket_clone/theme/app_colors.dart';

class PostInfo extends StatelessWidget {
  final PostDTO post;
  const PostInfo({super.key, required this.post});

  String _formatTimestamp(DateTime? time) {
    if (time == null) return '';
    // TODO: Triển khai logic "Vừa xong", "5d" v.v...

    // Dựa trên ảnh Loại 2 (image_fdefe8.jpg)
    if (post.authorFullname != 'Bạn') return '5d';
    return 'Vừa xong';
  }

  @override
  Widget build(BuildContext context) {
    final timeAgo = _formatTimestamp(post.createdAt);
    // Dựa trên ảnh Loại 2 (image_fdefe8.jpg)
    final authorName = post.authorFullname ?? 'T';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 12,
          // Yêu cầu 2: Cập nhật màu
          backgroundColor: AppColors.fieldBackground, // Thay vì Colors.white24
          child: Icon(
            Icons.person,
            size: 14,
            // Yêu cầu 2: Cập nhật màu
            color: AppColors.textSecondary,
          ), // Thay vì Colors.white70
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