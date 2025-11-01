import 'package:flutter/material.dart';
import 'package:locket_clone/theme/app_colors.dart';
import 'widgets/profile_avatar.dart';
import 'widgets/profile_option_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const String fullName = 'Anh Hoàng';
    const String email = '288hoanganh@gmail.com';
    const String initials = 'AH';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leadingWidth: 0,
        leading: const SizedBox.shrink(),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward, color: AppColors.textPrimary),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),

                // 1. Avatar
                const ProfileAvatar(initials: initials),
                const SizedBox(height: 12),

                // 2. Tên
                Text(
                  fullName,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                // 3. Chỉnh ảnh
                TextButton(
                  onPressed: () {},
                  child: const Text(
                    'Chỉnh ảnh',
                    style: TextStyle(
                      color: AppColors.brandYellow,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const Divider(),

                // 4. Sửa tên
                ProfileOptionTile(
                  icon: Icons.person,
                  title: 'Sửa tên',
                  subtitle: fullName,
                  onTap: () {},
                ),

                // 5. Thay đổi email
                ProfileOptionTile(
                  icon: Icons.mail,
                  title: 'Thay đổi địa chỉ email',
                  subtitle: email,
                  onTap: () {},
                ),
                const Divider(),

                // 6. Đăng xuất
                ProfileOptionTile(
                  icon: Icons.logout,
                  title: 'Đăng xuất',
                  onTap: () {},
                  color: AppColors.error,
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
