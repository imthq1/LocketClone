import 'package:flutter/material.dart';
import 'package:locket_clone/services/application/auth_controller.dart';
import 'package:locket_clone/theme/app_colors.dart';
import 'package:locket_clone/screens/friends/utils/initials.dart';
import 'package:locket_clone/shared/cloudinary_helper.dart';
import 'package:provider/provider.dart';
import 'widgets/profile_option_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final auth = context.read<AuthController>();
    await auth.logout();

    if (context.mounted) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/welcome', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.user;

    if (user == null) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.brandYellow),
        ),
      );
    }

    final String fullName = user.fullname;
    final String email = user.email;
    final String? imageUrl = user.image;
    final String initials = initialsFrom(fullName);
    final bool hasImage = imageUrl != null && imageUrl.isNotEmpty;

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
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0x33FFFFFF),
                      width: 8.0,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 82,
                    backgroundColor: AppColors.fieldBackground,
                    backgroundImage: hasImage
                        ? NetworkImage(buildCloudinaryUrl(imageUrl))
                        : null,
                    child: hasImage
                        ? null
                        : Text(
                            initials,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 12),

                // 2. Tên đầy đủ
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
                  onPressed: () {
                    // TODO: Logic chỉnh sửa ảnh đại diện
                  },
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
                  onTap: () {
                    // TODO: Logic sửa tên
                  },
                ),

                // 5. Thông tin email
                ProfileOptionTile(
                  icon: Icons.mail,
                  title: 'Địa chỉ email',
                  subtitle: email,
                  onTap: () {},
                ),
                const Divider(),

                // 6. Đăng xuất
                ProfileOptionTile(
                  icon: Icons.logout,
                  title: 'Đăng xuất',
                  onTap: () => _logout(context),
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
