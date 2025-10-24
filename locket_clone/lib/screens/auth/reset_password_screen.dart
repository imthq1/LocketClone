import 'package:flutter/material.dart';
import 'package:locket_clone/theme/app_colors.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Lấy email và otp đã xác thực từ arguments
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, String?>?;
    final email = args?['email'] ?? '...';
    final otp = args?['otp'] ?? '...';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Đặt lại mật khẩu',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            'Màn hình đặt lại mật khẩu cho $email.\n(OTP đã xác thực: $otp)',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
        ),
      ),
    );
  }
}