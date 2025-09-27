import 'dart:ui';
import 'package:flutter/material.dart';
import 'login_form.dart';
import 'app_logo.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Nền gradient
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? const [Color(0xFF0F172A), Color(0xFF1F2937)]
                      : const [Color(0xFFEEF2FF), Color(0xFFE0EAFF)],
                ),
              ),
            ),
          ),
          // Vệt màu mờ
          Positioned(
            top: -60,
            left: -40,
            child: _BlurBall(color: Colors.purpleAccent.withOpacity(0.35)),
          ),
          Positioned(
            bottom: -50,
            right: -30,
            child: _BlurBall(color: Colors.blueAccent.withOpacity(0.35)),
          ),

          // Nội dung
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                      decoration: BoxDecoration(
                        color: isDark
                            ? Colors.white.withOpacity(0.04)
                            : Colors.white.withOpacity(0.65),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark
                              ? Colors.white.withOpacity(0.08)
                              : Colors.white.withOpacity(0.5),
                        ),
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 40,
                            spreadRadius: -10,
                            offset: const Offset(0, 20),
                            color: Colors.black.withOpacity(0.14),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const AppLogo(),
                          const SizedBox(height: 12),
                          Text(
                            'Chào mừng trở lại 👋',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Đăng nhập để tiếp tục chia sẻ khoảnh khắc như Locket.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 18),
                          // Form
                          const LoginForm(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlurBall extends StatelessWidget {
  final Color color;
  const _BlurBall({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 220,
      height: 220,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }
}
