import 'package:flutter/material.dart';
import 'package:locket_clone/services/application/friends_controller.dart';
import 'package:locket_clone/theme/app_colors.dart';
import 'package:provider/provider.dart';

class HomeTopBar extends StatelessWidget {
  // TODO: Thêm các callbacks (onProfilePressed, onFriendsPressed)
  const HomeTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Giả sử số lượng bạn bè, bạn có thể lấy từ FriendsController
    final friendCount = 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nút Profile
          IconButton(
            onPressed: () {
              /* TODO: Mở màn hình profile */
            },
            icon: const Icon(
              Icons.person_outline,
              color: AppColors.textPrimary,
            ),
          ),

          // Nút Bạn bè
          TextButton.icon(
            onPressed: () {
              /* TODO: Mở màn hình bạn bè */
            },
            style: TextButton.styleFrom(
              backgroundColor: Colors.white10,
              foregroundColor: AppColors.textPrimary,
              shape: const StadiumBorder(),
            ),
            icon: const Icon(Icons.people_alt, size: 20),
            label: Text(
              '$friendCount Bạn bè',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),

          // Nút Chat
          IconButton(
            onPressed: () {
              // Load danh sách bạn bè trước khi mở màn hình chat
              context.read<FriendsController>().load();
              Navigator.pushNamed(context, '/chat');
            },
            icon: const Icon(
              Icons.chat_bubble_outline,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
