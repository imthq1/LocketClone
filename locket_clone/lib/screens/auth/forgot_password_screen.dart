import 'package:flutter/material.dart';
import 'package:locket_clone/theme/app_colors.dart';
import 'package:locket_clone/screens/auth/widgets/primary_auth_button.dart';
import 'package:locket_clone/screens/auth/widgets/primary_auth_input.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtl = TextEditingController();
  bool _isContinueEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _emailCtl.addListener(_validateInput);
  }

  @override
  void dispose() {
    _emailCtl.removeListener(_validateInput);
    _emailCtl.dispose();
    super.dispose();
  }

  void _validateInput() {
    final email = _emailCtl.text.trim();
    final isEmailValid = RegExp(r"^[^@\s]+@[^@\s]+\.[^@\s]+$").hasMatch(email);
    if (isEmailValid != _isContinueEnabled) {
      setState(() {
        _isContinueEnabled = isEmailValid;
      });
    }
  }

  /// Xử lý khi nhấn nút "Tiếp tục"
  Future<void> _submit() async {
    if (!_isContinueEnabled) return;

    setState(() => _isLoading = true);

    // TODO: Triển khai gọi API gửi mã khôi phục đến email

    // Giả lập một cuộc gọi API
    await Future.delayed(const Duration(seconds: 1));

    // In ra console để kiểm tra
    print('Gửi yêu cầu khôi phục cho: ${_emailCtl.text.trim()}');

    if (!mounted) return;
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã gửi email khôi phục (nếu tài khoản tồn tại).'),
        backgroundColor: AppColors.success.withOpacity(0.9),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                              'Khôi phục tài khoản',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Nhập email của bạn để nhận mã khôi phục.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 28),
                            PrimaryAuthInput(
                              controller: _emailCtl,
                              hintText: 'your-mail@gmail.com',
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 24),
                            PrimaryAuthButton(
                              label: 'Tiếp tục →',
                              isLoading: _isLoading,
                              onPressed: _isContinueEnabled ? _submit : null,
                            ),
                          ],
                        ),
                      ),
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
