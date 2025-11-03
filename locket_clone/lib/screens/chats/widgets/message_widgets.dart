import 'package:flutter/material.dart';
import 'package:locket_clone/screens/chats/chat_screen.dart';
import 'package:locket_clone/services/data/models/chat_dto.dart';
import 'package:locket_clone/services/data/models/user_dto.dart';
import 'package:locket_clone/theme/app_colors.dart';
import 'package:locket_clone/shared/cloudinary_helper.dart';
import 'package:locket_clone/screens/friends/utils/initials.dart';

class ChatRow extends StatelessWidget {
  final UserDTO user;
  const ChatRow({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final name = (user.fullname.isNotEmpty) ? user.fullname : user.email;
    final avatarUrl = (user.image ?? '').trim();

    return ListTile(
      onTap: () {
        final partner = ChatUserDTO(
          id: user.id,
          email: user.email,
          fullname: user.fullname,
          imageUrl: user.image,
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                ChatScreen(emailRq: user.email, partnerPrefill: partner),
          ),
        );
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(color: Colors.black87, blurRadius: 6, spreadRadius: 1),
          ],

          border: Border.all(
            color: AppColors.textHint.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: CircleAvatar(
          backgroundColor: AppColors.fieldBackground,
          backgroundImage: avatarUrl.isNotEmpty
              ? NetworkImage(buildCloudinaryUrl(avatarUrl))
              : null,
          child: avatarUrl.isEmpty
              ? Text(
                  initialsFrom(name),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                  ),
                )
              : null,
        ),
      ),
      title: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: const Text(
        'Say hi 👋',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [Icon(Icons.chevron_right, color: AppColors.textHint)],
      ),
    );
  }
}

class LoadingList extends StatelessWidget {
  const LoadingList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 8,
      separatorBuilder: (_, __) =>
          Divider(height: 1, color: AppColors.fieldBackground, indent: 72),
      itemBuilder: (_, __) => ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: CircleAvatar(
          radius: 27,
          backgroundColor: AppColors.fieldBackground,
        ),
        title: ShimmerBar(width: 140),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 6),
          child: ShimmerBar(width: 90),
        ),
      ),
    );
  }
}

class ShimmerBar extends StatelessWidget {
  final double width;
  const ShimmerBar({super.key, required this.width});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 12,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.fieldBackground,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
