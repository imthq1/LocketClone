import 'package:flutter/material.dart';
import 'package:locket_clone/theme/app_colors.dart';

class FriendPostActions extends StatelessWidget {
  const FriendPostActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.fieldBackground,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Text(
                'Gửi tin nhắn...',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
              ),
            ),
          ),

          _EmojiButton(emoji: '💛', onPressed: () {}),
          _EmojiButton(emoji: '🔥', onPressed: () {}),
          _EmojiButton(emoji: '😍', onPressed: () {}),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.add_circle_outline,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmojiButton extends StatelessWidget {
  final String emoji;
  final VoidCallback onPressed;
  const _EmojiButton({required this.emoji, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Text(emoji, style: const TextStyle(fontSize: 24)),
    );
  }
}
