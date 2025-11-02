// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:locket_clone/services/data/models/post_dto.dart';
import 'package:locket_clone/shared/cloudinary_helper.dart';
import 'package:provider/provider.dart';
import 'package:locket_clone/services/application/auth_controller.dart';
import 'package:locket_clone/services/application/chat_controller.dart';
import 'package:locket_clone/theme/app_colors.dart';

class FriendPostActions extends StatelessWidget {
  final PostDTO post;
  const FriendPostActions({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => _openComposer(context),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.fieldBackground,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Text(
                  'Gửi tin nhắn...',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ),
          _EmojiButton(emoji: '💛', onPressed: () => _sendQuick(context, '💛')),
          _EmojiButton(emoji: '🔥', onPressed: () => _sendQuick(context, '🔥')),
          _EmojiButton(emoji: '😍', onPressed: () => _sendQuick(context, '😍')),
          IconButton(
            onPressed: () => _openComposer(context),
            icon: const Icon(
              Icons.add_circle_outline,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendQuick(BuildContext context, String content) async {
    final chat = context.read<ChatController>();
    final auth = context.read<AuthController>();
    final meId = auth.user?.id;
    if (meId == null) {
      _toast(context, 'Bạn cần đăng nhập.');
      return;
    }

    try {
      // đảm bảo có conversation 1-1 với chủ bài post
      await chat.loadConversationByEmail(post.authorEmail!);
      await chat.sendMessage(
        senderId: meId,
        content: content,
        image: post.image,
      );
      _toast(context, 'Đã gửi 👌');
    } catch (e) {
      _toast(context, 'Gửi thất bại: $e');
    }
  }

  Future<void> _openComposer(BuildContext context) async {
    final textCtrl = TextEditingController();
    final imageUrl = buildCloudinaryUrl(post.image);
    final res = await showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF121212),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // preview ảnh bài post
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(imageUrl, height: 140, fit: BoxFit.cover),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: textCtrl,
                style: const TextStyle(color: Colors.white),
                maxLines: 4,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Viết gì đó kèm ảnh này…',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF1A1A1A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0x33FFFFFF)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0x33FFFFFF)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Color(0x66FFFFFF)),
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (v) => Navigator.of(ctx).pop(v.trim()),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(null),
                    child: const Text('Hủy'),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () =>
                        Navigator.of(ctx).pop(textCtrl.text.trim()),
                    child: const Text('Gửi'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        );
      },
    );

    final content = res?.trim() ?? '';
    if (content.isEmpty) return;

    final chat = context.read<ChatController>();
    final auth = context.read<AuthController>();
    final meId = auth.user?.id;
    if (meId == null) {
      _toast(context, 'Bạn cần đăng nhập.');
      return;
    }

    try {
      await chat.loadConversationByEmail(post.authorEmail!);
      await chat.sendMessage(
        senderId: meId,
        content: content,
        image: post.image,
      );
      _toast(context, 'Đã gửi 👌');
    } catch (e) {
      _toast(context, 'Gửi thất bại: $e');
    }
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
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
