import 'package:flutter/material.dart';
import 'package:locket_clone/services/data/models/friend_request_sent_dto.dart';
import 'package:locket_clone/shared/cloudinary_helper.dart';
import 'package:locket_clone/theme/app_colors.dart';
import '../utils/initials.dart';

class SentRequestTile extends StatelessWidget {
  final FriendRqSentItemDTO item;
  final VoidCallback onCancel;

  const SentRequestTile({
    super.key,
    required this.item,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final avatarUrl = (item.targetAvatar ?? '');
    final displayName = (item.targetFullname.isNotEmpty)
        ? item.targetFullname
        : item.targetEmail;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        backgroundColor: AppColors.fieldBackground,
        backgroundImage: avatarUrl.isNotEmpty
            ? NetworkImage(buildCloudinaryUrl(avatarUrl))
            : null,
        child: avatarUrl.isEmpty
            ? Text(
                initialsFrom(displayName),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                ),
              )
            : null,
      ),
      title: Text(
        displayName,
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
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          minimumSize: const Size(40, 40),
        ),
        icon: const Icon(Icons.close_rounded),
      ),
    );
  }
}
