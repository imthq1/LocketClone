import 'package:flutter/material.dart';
import 'package:locket_clone/services/application/auth_controller.dart';
import 'package:locket_clone/services/application/friends_controller.dart';
import 'package:locket_clone/theme/app_colors.dart';
import 'package:provider/provider.dart';

class HomeTopBar extends StatelessWidget {
  final int sumUser;
  const HomeTopBar({super.key, this.sumUser = 0});

  @override
  Widget build(BuildContext context) {
    final friendCount = sumUser;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nút Profile
          IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/profile');
            },
            icon: const Icon(Icons.person, color: AppColors.textPrimary),
          ),
          const SizedBox(width: 1),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthController>().logout();
              if (context.mounted) {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
          ),
          // Nút Bạn bè
          TextButton.icon(
            onPressed: () {
              context.read<FriendsController>().load();
              Navigator.pushReplacementNamed(context, '/friends');
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
              context.read<FriendsController>().load();
              Navigator.pushReplacementNamed(context, '/chat');
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
