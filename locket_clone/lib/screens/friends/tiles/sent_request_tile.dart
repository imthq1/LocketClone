import 'package:flutter/material.dart';
import 'package:locket_clone/services/data/models/friend_request_sent_dto.dart';
import 'package:locket_clone/theme/app_colors.dart';
import '../utils/initials.dart';

class SentRequestTile extends StatelessWidget {
  final FriendRqSentItemDTO item;
  final VoidCallback onCancel;

  const SentRequestTile({required this.item, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final avatar = item.targetAvatar;
    final name = (item.targetFullname.isNotEmpty)
        ? item.targetFullname
        : item.targetEmail;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.background,
        backgroundImage: (avatar != null && avatar.isNotEmpty)
            ? NetworkImage(avatar)
            : null,
        child: (avatar == null || avatar.isEmpty)
            ? Text(
                initialsFrom(name),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
      title: Text(
        name,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: const Text('đã gửi lời mời kết bạn'),
      trailing: IconButton(
        tooltip: 'Huỷ lời mời',
        onPressed: onCancel,
        style: IconButton.styleFrom(
          backgroundColor: Colors.red.shade500,
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          minimumSize: const Size(40, 40),
        ),
        icon: const Icon(Icons.close_rounded),
      ),
    );
  }
}
