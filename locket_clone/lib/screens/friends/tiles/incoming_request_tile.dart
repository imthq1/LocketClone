import 'package:flutter/material.dart';
import 'package:locket_clone/services/data/models/friend_request_dto.dart';
import 'package:locket_clone/shared/cloudinary_helper.dart';
import 'package:locket_clone/theme/app_colors.dart';
import '../utils/initials.dart';

class IncomingRequestTile extends StatelessWidget {
  final FriendRequestItemDTO item;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const IncomingRequestTile({
    super.key,
    required this.item,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final avatarUrl = item.requesterAvatar;
    final displayName = item.requesterFullname.isNotEmpty
        ? item.requesterFullname
        : item.requesterEmail;

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
      trailing: Wrap(
        spacing: 8,
        children: [
          // ❌ Hủy: nền đỏ, icon trắng
          IconButton(
            onPressed: onReject,
            tooltip: 'Huỷ',
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              minimumSize: const Size(40, 40), // chỉnh kích thước nút
            ),
            icon: const Icon(Icons.close_rounded),
          ),
          // ✅ Đồng ý: nền vàng (brand), icon trắng
          IconButton(
            onPressed: onAccept,
            tooltip: 'Đồng ý',
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              minimumSize: const Size(40, 40),
            ),
            icon: const Icon(Icons.check_rounded),
          ),
        ],
      ),
    );
  }
}
