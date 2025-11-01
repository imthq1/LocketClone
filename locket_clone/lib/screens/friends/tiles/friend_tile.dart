import 'package:flutter/material.dart';
import 'package:locket_clone/theme/app_colors.dart';
import 'package:locket_clone/services/data/models/user_dto.dart';
import '../utils/initials.dart';

class FriendTile extends StatelessWidget {
  final UserDTO user;
  final VoidCallback? onUnfriend;
  const FriendTile({required this.user, this.onUnfriend});

  @override
  Widget build(BuildContext context) {
    final url = user.image;
    final displayName = (user.fullname.isNotEmpty)
        ? user.fullname
        : (user.email);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: AppColors.background,
        backgroundImage: (url != null && url.isNotEmpty)
            ? NetworkImage(url)
            : null,
        child: (url == null || url.isEmpty)
            ? Text(
                initialsFrom(displayName),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
      title: Text(
        displayName,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
        ),
      ),
      // ✅ Nút X giống phần “incoming/sent”
      trailing: IconButton(
        tooltip: 'Hủy kết bạn',
        onPressed: onUnfriend,
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
