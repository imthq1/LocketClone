import 'dart:async';
import 'package:flutter/material.dart';
import 'package:locket_clone/services/application/auth_controller.dart';
import 'package:locket_clone/theme/app_colors.dart';
import 'package:locket_clone/screens/auth/widgets/primary_auth_button.dart';
import 'package:locket_clone/screens/auth/widgets/primary_auth_input.dart';
import 'package:provider/provider.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});
  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtl = TextEditingController();
  bool _isContinueEnabled = false;
  Timer? _errorTimer;
  int _errorCountdown = 0;

  @override
  void initState() {
    super.initState();
    _emailCtl.addListener(_validateInput);
  }

  @override
  void dispose() {
    _emailCtl.removeListener(_validateInput);
    _emailCtl.dispose();
    _errorTimer?.cancel(); // <-- Hủy timer khi tắt màn hình
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

  void _startErrorCountdown() {
    _errorTimer?.cancel();
    setState(() {
      _errorCountdown = 5;
    });

    _errorTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_errorCountdown > 0) {
        setState(() {
          _errorCountdown--;
        });
      } else {
        timer.cancel();
        _errorTimer = null;
      }
    });
  }

  Future<void> _submit() async {
    if (!_isContinueEnabled || _errorCountdown > 0) return;

    final email = _emailCtl.text.trim();
    final auth = context.read<AuthController>();

    final bool success = await auth.sendResetOtp(email);

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pushNamed('/otp-verify', arguments: email);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Bạn phải đợi 60 giây trước khi yêu cầu gửi lại OTP cho email này',
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          backgroundColor: AppColors.error.withValues(alpha: 0.9),
        ),
      );
      _startErrorCountdown();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthController>().isLoading;
    final bool isButtonDisabled =
        isLoading || !_isContinueEnabled || _errorCountdown > 0;

    final String buttonLabel = _errorCountdown > 0
        ? 'Thử lại sau ($_errorCountdown\s)'
        : 'Tiếp tục';

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
                              hintText: 'Nhập email của bạn',
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 24),
                            PrimaryAuthButton(
                              label: buttonLabel,
                              isLoading: isLoading,
                              onPressed: isButtonDisabled ? null : _submit,
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
