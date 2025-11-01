import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:locket_clone/services/application/auth_controller.dart';
import 'package:locket_clone/theme/app_colors.dart';
import 'package:locket_clone/screens/auth/widgets/primary_auth_button.dart';
import 'package:locket_clone/screens/auth/widgets/primary_auth_input.dart';

class CreatePasswordScreen extends StatefulWidget {
  const CreatePasswordScreen({super.key});

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final _passwordCtl = TextEditingController();
  final _confirmPasswordCtl = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isButtonEnabled = false;
  bool _isResetFlow = false;
  Map<String, dynamic>? _args;

  @override
  void initState() {
    super.initState();
    _passwordCtl.addListener(_validateInput);
    _confirmPasswordCtl.addListener(_validateInput);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final routeName = ModalRoute.of(context)?.settings.name;
    _isResetFlow = routeName == '/reset-password';
    _args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
  }

  @override
  void dispose() {
    _passwordCtl.removeListener(_validateInput);
    _confirmPasswordCtl.removeListener(_validateInput);
    _passwordCtl.dispose();
    _confirmPasswordCtl.dispose();
    super.dispose();
  }

  void _validateInput() {
    final password = _passwordCtl.text;
    final confirmPassword = _confirmPasswordCtl.text;

    final bool isEnabled =
        password.isNotEmpty &&
        confirmPassword.isNotEmpty &&
        password == confirmPassword &&
        password.length >= 6;

    if (isEnabled != _isButtonEnabled) {
      setState(() {
        _isButtonEnabled = isEnabled;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    String errorMessage = message;
    final apiErrorPrefix = RegExp(r'ApiException\(\d*\): ');
    errorMessage = errorMessage.replaceFirst(apiErrorPrefix, '');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(errorMessage),
        backgroundColor: AppColors.error.withValues(alpha: 0.9),
      ),
    );
  }

  Future<void> _submit() async {
    final auth = context.read<AuthController>();
    final password = _passwordCtl.text.trim();

    if (_isResetFlow) {
      // --- LUỒNG ĐẶT LẠI MẬT KHẨU ---
      final email = _args?['email'] as String?;

      if (email == null) {
        _showErrorSnackBar('Thiếu thông tin email. Vui lòng thử lại.');
        return;
      }

      final bool success = await auth.resetPassword(
        email: email,
        newPassword: password,
      );
      
      if (!mounted) return;
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Đã đặt lại mật khẩu thành công. Vui lòng đăng nhập lại.',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            backgroundColor: AppColors.success.withValues(alpha: 0.9),
          ),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        _showErrorSnackBar(auth.error ?? 'Đặt lại mật khẩu thất bại.');
      }
    } else {
      // --- LUỒNG ĐĂNG KÝ ---
      final email = _args?['email'] as String?;
      final fullname = _args?['fullname'] as String?;

      if (email == null || fullname == null) {
        _showErrorSnackBar(
          'Thiếu thông tin email hoặc họ tên. Vui lòng thử lại.',
        );
        return;
      }

      await auth.registerThenLogin(
        email: email,
        password: password,
        fullname: fullname,
      );

      if (!mounted) return;
      if (auth.user != null) {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/home', (route) => false);
      } else if (auth.error != null) {
        _showErrorSnackBar(auth.error!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthController>().isLoading;

    final String title = _isResetFlow ? 'Đặt lại mật khẩu' : 'Tạo mật khẩu';
    final String hint = _isResetFlow ? 'Mật khẩu mới' : 'Mật khẩu';
    final String confirmHint = _isResetFlow
        ? 'Xác nhận mật khẩu mới'
        : 'Xác nhận mật khẩu';
    final String buttonLabel = _isResetFlow ? 'Hoàn tất' : 'Đăng ký';

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
                                  Text(
                                    title,
                                    style: const TextStyle(
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
                              controller: _passwordCtl,
                              hintText: '$hint (tối thiểu 6 ký tự)',
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
                              hintText: confirmHint,
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
                  PrimaryAuthButton(
                    label: buttonLabel,
                    isLoading: isLoading,
                    onPressed: _isButtonEnabled ? _submit : null,
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
