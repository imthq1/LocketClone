import 'package:flutter/material.dart';
import 'package:locket_clone/services/data/models/post_dto.dart';
import 'package:locket_clone/shared/cloudinary_helper.dart';
import 'package:locket_clone/theme/app_colors.dart'; // Import AppColors

class PostCard extends StatelessWidget {
  final PostDTO post;
  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final bool hasCaption = post.caption.isNotEmpty;
    final String displayText = hasCaption ? post.caption : '...';
    final FontWeight displayWeight = hasCaption
        ? FontWeight.w700
        : FontWeight.w500;
    final imageUrl = buildCloudinaryUrl(post.image);

    return AspectRatio(
      aspectRatio: 1.0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32.0),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              // Yêu cầu 2: Cập nhật màu
              color: AppColors.fieldBackground, // Thay vì Colors.white10
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.error_outline,
                          // Yêu cầu 2: Cập nhật màu
                          color: AppColors.textHint,
                        ); // Thay vì Colors.white38
                      },
                    )
                  : const Icon(
                      Icons.image_not_supported,
                      // Yêu cầu 2: Cập nhật màu
                      color: AppColors.textHint,
                    ), // Thay vì Colors.white38
            ),
            Positioned(
              bottom: 20,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    displayText,
                    style: TextStyle(
                      // Yêu cầu 2: Cập nhật màu
                      color: AppColors.textPrimary, // Thay vì Colors.white
                      fontSize: 16,
                      fontWeight: displayWeight,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}