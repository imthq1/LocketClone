import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  const AppLogo({super.key, this.size = 56});

  @override
  Widget build(BuildContext context) {
    // Logo bo tròn + viền mờ nhẹ
    return Container(
      width: size + 20,
      height: size + 20,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          colors: [Color(0xFF7C3AED), Color(0xFF06B6D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            blurRadius: 24,
            offset: const Offset(0, 12),
            color: Colors.black.withOpacity(0.18),
          ),
        ],
      ),
      child: Center(
        child: ClipOval(
          child: Image.asset(
            // Giữ nguyên vị trí bạn đang dùng
            'lib/data/assets/locket_app_icon-01.png',
            width: size,
            height: size,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
