import 'package:flutter/material.dart';
import 'package:locket_clone/services/data/models/friend_request_dto.dart';
import 'package:locket_clone/theme/app_colors.dart';
import '../utils/initials.dart';

class IncomingRequestTile extends StatelessWidget {
  final FriendRequestItemDTO item;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const IncomingRequestTile({
    required this.item,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = item.requesterAvatar;
    final name = item.requesterFullname.isNotEmpty
        ? item.requesterFullname
        : item.requesterEmail;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.background,
        backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
        child: avatar.isEmpty
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
      trailing: Wrap(
        spacing: 8,
        children: [
          // ❌ Hủy: nền đỏ, icon trắng
          IconButton(
            onPressed: onReject,
            tooltip: 'Huỷ',
            style: IconButton.styleFrom(
              backgroundColor: Colors.red.shade500,
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
              backgroundColor: AppColors.brandYellow,
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
