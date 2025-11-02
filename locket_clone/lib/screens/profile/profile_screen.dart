import 'package:flutter/material.dart';
import 'package:locket_clone/services/application/auth_controller.dart';
import 'package:locket_clone/theme/app_colors.dart';
import 'package:locket_clone/screens/friends/utils/initials.dart';
import 'package:locket_clone/shared/cloudinary_helper.dart';
import 'package:provider/provider.dart';
import 'widgets/profile_option_tile.dart';
import 'package:image_picker/image_picker.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isRenaming = false;
  bool _isUploadingAvatar = false;

  Future<void> _logout(BuildContext context) async {
    final auth = context.read<AuthController>();
    await auth.logout();

    if (context.mounted) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil('/welcome', (route) => false);
    }
  }

  Future<String?> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? file = await picker.pickImage(source: ImageSource.gallery);
      return file?.path;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không thể chọn ảnh: $e')));
      }
      return null;
    }
  }

  Future<void> _editAvatar() async {
    if (_isUploadingAvatar) return;

    final filePath = await _pickImage();
    if (filePath == null || !context.mounted) return;

    setState(() => _isUploadingAvatar = true);
    final auth = context.read<AuthController>();

    final success = await auth.updateAvatar(filePath);

    if (context.mounted) {
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.error ?? 'Cập nhật ảnh đại diện thất bại'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      setState(() => _isUploadingAvatar = false);
    }
  }

  Future<void> _editName(String currentName) async {
    if (_isRenaming) return;

    final nameController = TextEditingController(text: currentName);
    final newName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text(
          'Đổi tên của bạn',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: TextField(
          controller: nameController,
          autofocus: true,
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Nhập tên mới',
            hintStyle: TextStyle(color: AppColors.textHint),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Huỷ'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(nameController.text.trim()),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );

    if (newName == null ||
        newName.isEmpty ||
        newName == currentName ||
        !context.mounted) {
      return;
    }

    setState(() => _isRenaming = true);
    final auth = context.read<AuthController>();
    final success = await auth.updateFullname(newName);

    if (context.mounted) {
      if (!success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.error ?? 'Cập nhật tên thất bại'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      setState(() => _isRenaming = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.user;
    final isAuthLoading = auth.isLoading;

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
    final bool isBusy = isAuthLoading || _isRenaming || _isUploadingAvatar;

    return AbsorbPointer(
      absorbing: isBusy,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          leadingWidth: 0,
          leading: const SizedBox.shrink(),
          actions: [
            IconButton(
              icon: const Icon(
                Icons.arrow_forward,
                color: AppColors.textPrimary,
              ),
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
                    onPressed: _editAvatar,
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
                    onTap: () => _editName(fullName),
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
      ),
    );
  }
}
