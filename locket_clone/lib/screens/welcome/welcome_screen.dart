import 'package:flutter/material.dart';
import 'package:locket_clone/screens/welcome/widgets/primary_btn.dart';
import 'package:locket_clone/theme/app_colors.dart';
import './widgets/ggSignIn_btn.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({
    super.key,
    required this.onSignUp,
    required this.onSignIn,
    this.phoneImageAsset = 'lib/assets/phone_mock.png',
    this.logoAssetPath = 'lib/assets/locket_app_icon.png',
  });

  final VoidCallback onSignUp;
  final VoidCallback onSignIn;
  final String phoneImageAsset;
  final String logoAssetPath;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: Image.asset(
                  phoneImageAsset,
                  width: size.width,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.brandYellow,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Image.asset(logoAssetPath, fit: BoxFit.contain),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Locket',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: .2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Ảnh trực tiếp từ bạn bè,\nngay trên màn hình chính',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 18,
                height: 1.35,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 38),

            PrimaryBtn(label: 'Tạo một tài khoản', onPressed: onSignUp),
            const SizedBox(height: 16),

            GoogleSignInButton(
              onPressed: () {
                print('Google Sign-In pressed');
              },
            ),
            const SizedBox(height: 8),

            TextButton(
              onPressed: onSignIn,
              child: const Text(
                'Đăng nhập bằng email',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
