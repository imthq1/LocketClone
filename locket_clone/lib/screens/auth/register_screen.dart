import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:locket_clone/services/application/auth_controller.dart';
import 'package:locket_clone/theme/app_colors.dart';
import 'package:locket_clone/screens/auth/widgets/primary_auth_button.dart';
import 'package:locket_clone/screens/auth/widgets/primary_auth_input.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailCtl = TextEditingController();
  final _passwordCtl = TextEditingController();
  final _confirmPasswordCtl = TextEditingController();
  final _fullnameCtl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isRegisterEnabled = false;

  @override
  void initState() {
    super.initState();
    _fullnameCtl.addListener(_validateInput);
    _emailCtl.addListener(_validateInput);
    _passwordCtl.addListener(_validateInput);
    _confirmPasswordCtl.addListener(_validateInput);
  }

  @override
  void dispose() {
    _fullnameCtl.removeListener(_validateInput);
    _emailCtl.removeListener(_validateInput);
    _passwordCtl.removeListener(_validateInput);
    _confirmPasswordCtl.removeListener(_validateInput);
    _fullnameCtl.dispose();
    _emailCtl.dispose();
    _passwordCtl.dispose();
    _confirmPasswordCtl.dispose();
    super.dispose();
  }

  void _validateInput() {
    final fullname = _fullnameCtl.text.trim();
    final email = _emailCtl.text.trim();
    final password = _passwordCtl.text;
    final confirmPassword = _confirmPasswordCtl.text;
    final isEmailValid = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$").hasMatch(email);
    final bool isEnabled =
        fullname.isNotEmpty &&
        email.isNotEmpty &&
        password.isNotEmpty &&
        confirmPassword.isNotEmpty &&
        isEmailValid &&
        password == confirmPassword &&
        password.length >= 6;

    if (isEnabled != _isRegisterEnabled) {
      setState(() {
        _isRegisterEnabled = isEnabled;
      });
    }
  }

  Future<void> _submit() async {
    final auth = context.read<AuthController>();
    await auth.registerThenLogin(
      email: _emailCtl.text.trim(),
      password: _passwordCtl.text.trim(),
      fullname: _fullnameCtl.text.trim(),
    );

    if (!mounted) return;
    if (auth.user != null) {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } else if (auth.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(auth.error!)));
    }
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
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const SizedBox(height: 60),
                            Center(
                              child: Column(
                                children: [
                                  Image.asset(
                                    'lib/assets/locket_app_icon.png',
                                    height: 64,
                                    width: 64,
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Tạo tài khoản',
                                    style: TextStyle(
                                      color: AppColors.textPrimary,
                                      fontSize: 28,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            PrimaryAuthInput(
                              controller: _fullnameCtl,
                              hintText: 'Họ và tên',
                              keyboardType: TextInputType.name,
                            ),
                            const SizedBox(height: 14),
                            PrimaryAuthInput(
                              controller: _emailCtl,
                              hintText: 'Email của bạn',
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 14),
                            PrimaryAuthInput(
                              controller: _passwordCtl,
                              hintText: 'Mật khẩu (tối thiểu 6 ký tự)',
                              obscureText: _obscurePassword,
                              keyboardType: TextInputType.visiblePassword,
                              suffixIcon: IconButton(
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            PrimaryAuthInput(
                              controller: _confirmPasswordCtl,
                              hintText: 'Xác nhận mật khẩu',
                              obscureText: _obscureConfirmPassword,
                              keyboardType: TextInputType.visiblePassword,
                              suffixIcon: IconButton(
                                onPressed: () => setState(
                                  () => _obscureConfirmPassword =
                                      !_obscureConfirmPassword,
                                ),
                                icon: Icon(
                                  _obscureConfirmPassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10, top: 16),
                    child: Opacity(
                      opacity: 0.6,
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            height: 1.35,
                          ),
                          children: [
                            TextSpan(
                              text: 'Bằng cách nhấn Tiếp tục, bạn đồng ý với ',
                            ),
                            TextSpan(
                              text: 'Điều khoản dịch vụ',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            TextSpan(text: ' và '),
                            TextSpan(
                              text: 'Chính sách quyền riêng tư',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  PrimaryAuthButton(
                    label: 'Tiếp tục →',
                    isLoading: isLoading,
                    onPressed: _isRegisterEnabled ? _submit : null,
                  ),
                  const SizedBox(height: 24),
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
