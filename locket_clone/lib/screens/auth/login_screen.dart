import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:locket_clone/services/application/auth_controller.dart';
import 'package:locket_clone/theme/app_colors.dart';
import 'package:locket_clone/screens/auth/widgets/primary_auth_button.dart';
import 'package:locket_clone/screens/auth/widgets/primary_auth_input.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtl = TextEditingController();
  final _passCtl = TextEditingController();
  bool _obscure = true;
  bool _isLoginEnabled = false;

  @override
  void initState() {
    super.initState();
    _emailCtl.addListener(_validateInput);
    _passCtl.addListener(_validateInput);
  }

  @override
  void dispose() {
    _emailCtl.removeListener(_validateInput);
    _passCtl.removeListener(_validateInput);
    _emailCtl.dispose();
    _passCtl.dispose();
    super.dispose();
  }

  void _validateInput() {
    final email = _emailCtl.text.trim();
    final password = _passCtl.text.trim();
    final isEmailValid = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$").hasMatch(email);
    final bool isEnabled =
        email.isNotEmpty && password.isNotEmpty && isEmailValid;
    if (isEnabled != _isLoginEnabled) {
      setState(() {
        _isLoginEnabled = isEnabled;
      });
    }
  }

  Future<void> _signin() async {
    final auth = context.read<AuthController>();
    await auth.login(_emailCtl.text.trim(), _passCtl.text.trim());

    if (!mounted) return;
    if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          content: Text(auth.error!),
        ),
      );
      return;
    }

    if (auth.user != null) {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    }
  }

  void _signup() {
    Navigator.of(context).pushNamed('/register');
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthController>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'lib/assets/locket_app_icon.png',
                              height: 64,
                              width: 64,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Đăng nhập',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 28),
                            PrimaryAuthInput(
                              controller: _emailCtl,
                              hintText: 'Email',
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 14),
                            PrimaryAuthInput(
                              controller: _passCtl,
                              hintText: 'Mật khẩu',
                              obscureText: _obscure,
                              suffixIcon: IconButton(
                                splashRadius: 20,
                                icon: Icon(
                                  _obscure
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: AppColors.secondaryText,
                                ),
                                onPressed: () =>
                                    setState(() => _obscure = !_obscure),
                              ),
                            ),
                            const SizedBox(height: 24),
                            PrimaryAuthButton(
                              label: 'Đăng nhập',
                              isLoading: isLoading,
                              onPressed: _isLoginEnabled ? _signin : null,
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: isLoading ? null : _signup,
                              child: const Text(
                                'Chưa có tài khoản? Đăng ký ngay',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24.0, top: 16.0),
                    child: Text(
                      'Bằng việc tiếp tục, bạn đồng ý với Điều khoản và Chính sách của chúng tôi.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textHint, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 8,
              left: 12,
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white10,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
