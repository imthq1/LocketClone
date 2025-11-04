import 'package:flutter/material.dart';
import 'package:locket_clone/theme/app_colors.dart';
import 'package:locket_clone/services/data/models/user_dto.dart';
import 'package:locket_clone/shared/cloudinary_helper.dart';
import '../utils/initials.dart';

class FriendTile extends StatelessWidget {
  final UserDTO user;
  final VoidCallback? onUnfriend;
  const FriendTile({required this.user, this.onUnfriend});

  @override
  Widget build(BuildContext context) {
    final avatarUrl = (user.image ?? '').trim();
    final displayName = (user.fullname.isNotEmpty)
        ? user.fullname
        : (user.email);

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
          fontWeight: FontWeight.w800,
        ),
      ),
      trailing: IconButton(
        tooltip: 'Hủy kết bạn',
        onPressed: onUnfriend,
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
