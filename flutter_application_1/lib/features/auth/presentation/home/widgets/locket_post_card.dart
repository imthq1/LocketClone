import 'dart:ui';
import 'package:flutter/material.dart';

class LocketPostCard extends StatelessWidget {
  final String username;
  final String timeText;
  final String avatarAsset;
  final String imageAsset;
  final bool liked;
  final VoidCallback onLike;
  final VoidCallback onComment;
  final VoidCallback onSend;

  const LocketPostCard({
    super.key,
    required this.username,
    required this.timeText,
    required this.avatarAsset,
    required this.imageAsset,
    required this.liked,
    required this.onLike,
    required this.onComment,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withOpacity(0.06)
                : Colors.white.withOpacity(0.72),
            border: Border.all(color: Colors.white.withOpacity(0.35)),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                blurRadius: 24,
                offset: const Offset(0, 14),
                color: Colors.black.withOpacity(0.12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundImage: AssetImage(avatarAsset),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            username,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            timeText,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color
                                  ?.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.more_horiz_rounded),
                      tooltip: 'Tùy chọn',
                    ),
                  ],
                ),
              ),

              // Ảnh
              AspectRatio(
                aspectRatio: 1, // vuông như Locket
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(imageAsset, fit: BoxFit.cover),
                ),
              ),

              // Actions
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: onLike,
                      icon: Icon(
                        liked
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: liked ? Colors.pinkAccent : null,
                      ),
                    ),
                    IconButton(
                      onPressed: onComment,
                      icon: const Icon(Icons.mode_comment_outlined),
                    ),
                    IconButton(
                      onPressed: onSend,
                      icon: const Icon(Icons.send_outlined),
                    ),
                    const Spacer(),
                    FilledButton.tonalIcon(
                      onPressed: () {},
                      icon: const Icon(Icons.reply_rounded, size: 18),
                      label: const Text('Phản hồi'),
                      style: FilledButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
