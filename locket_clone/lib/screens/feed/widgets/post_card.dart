import 'package:flutter/material.dart';
import 'package:locket_clone/services/data/models/post_dto.dart';
import 'package:locket_clone/shared/cloudinary_helper.dart';
import 'package:locket_clone/theme/app_colors.dart';

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
              color: AppColors.fieldBackground,
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
                          color: AppColors.textHint,
                        );
                      },
                    )
                  : const Icon(
                      Icons.image_not_supported,
                      color: AppColors.textHint,
                    ),
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
                    color: Colors.black.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    displayText,
                    style: TextStyle(
                      color: AppColors.textPrimary,
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