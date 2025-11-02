import 'dart:async';
import 'package:flutter/material.dart';
import 'package:locket_clone/services/application/auth_controller.dart';
import 'package:locket_clone/theme/app_colors.dart';
import 'package:locket_clone/screens/auth/widgets/primary_auth_button.dart';
import 'package:locket_clone/screens/auth/widgets/primary_auth_input.dart';
import 'package:provider/provider.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});
  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpCtl = TextEditingController();
  bool _isContinueEnabled = false;
  bool _isResending = false;
  Timer? _resendTimer;
  int _resendCountdown = 0;
  Timer? _verifyErrorTimer;
  String _verifyButtonLabel = 'Xác nhận';
  bool _isVerifyError = false;

  @override
  void initState() {
    super.initState();
    _otpCtl.addListener(_validateInput);
    _startResendCountdown();
  }

  @override
  void dispose() {
    _otpCtl.removeListener(_validateInput);
    _otpCtl.dispose();
    _resendTimer?.cancel();
    _verifyErrorTimer?.cancel();
    super.dispose();
  }

  void _validateInput() {
    final otp = _otpCtl.text.trim();
    final bool isEnabled = otp.length == 6;
    if (isEnabled != _isContinueEnabled) {
      setState(() {
        _isContinueEnabled = isEnabled;
      });
    }
  }

  String? _getEmailArg() {
    try {
      return ModalRoute.of(context)!.settings.arguments as String?;
    } catch (e) {
      return null;
    }
  }

  void _startResendCountdown() {
    _resendTimer?.cancel();
    setState(() {
      _resendCountdown = 60;
    });
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendCountdown > 0) {
        setState(() {
          _resendCountdown--;
        });
      } else {
        timer.cancel();
        _resendTimer = null;
      }
    });
  }

  void _showVerifyError() {
    _verifyErrorTimer?.cancel();
    setState(() {
      _isVerifyError = true;
      _verifyButtonLabel = 'OTP không chính xác';
    });

    _verifyErrorTimer = Timer(const Duration(seconds: 2), () {
      setState(() {
        _isVerifyError = false;
        _verifyButtonLabel = 'Xác nhận';
        _verifyErrorTimer = null;
      });
    });
  }

  Future<void> _submit() async {
    if (!_isContinueEnabled) return;

    final email = _getEmailArg();
    final otp = _otpCtl.text.trim();
    final auth = context.read<AuthController>();

    if (email == null) {
      _showVerifyError();
      return;
    }

    final bool isOtpValid = await auth.verifyResetOtp(email, otp);

    if (!mounted) return;

    if (isOtpValid) {
      _resendTimer?.cancel();
      _verifyErrorTimer?.cancel();
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/reset-password',
        (route) => route.isFirst,
        arguments: {'email': email},
      );
    } else {
      _showVerifyError();
    }
  }

  Future<void> _resendOtp() async {
    setState(() => _isResending = true);
    final email = _getEmailArg();
    final auth = context.read<AuthController>();

    if (email == null) {
      setState(() => _isResending = false);
      return;
    }

    final bool success = await auth.sendResetOtp(email);

    if (!mounted) return;
    setState(() => _isResending = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Đã gửi lại mã tới $email',
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          backgroundColor: AppColors.success.withValues(alpha: 0.9),
        ),
      );
      // Bắt đầu đếm ngược 60s (lần nữa)
      _startResendCountdown();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            auth.error ?? 'Gửi lại mã thất bại.',
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          backgroundColor: AppColors.error.withValues(alpha: 0.9),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final email = _getEmailArg();
    final isLoading = context.watch<AuthController>().isLoading;
    final bool canResend = !_isResending && _resendCountdown == 0 && !isLoading;
    String resendText;
    if (_isResending) {
      resendText = 'Đang gửi...';
    } else if (_resendCountdown > 0) {
      resendText = 'Gửi lại sau ($_resendCountdown giây)';
    } else {
      resendText = 'Gửi lại mã';
    }
    final bool canSubmit = _isContinueEnabled && !_isVerifyError;

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
                            const Text(
                              'Nhập mã xác thực',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 28,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Nếu tài khoản tồn tại một mã 6 chữ số sẽ được gửi đến\n${email ?? 'email của bạn'}.',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 28),
                            PrimaryAuthInput(
                              controller: _otpCtl,
                              hintText: '123456 (mã gồm 6 chữ số)',
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: 24),
                            PrimaryAuthButton(
                              label: _verifyButtonLabel,
                              isLoading: isLoading,
                              onPressed: canSubmit ? _submit : null,
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: canResend ? _resendOtp : null,
                              child: Text(
                                resendText,
                                style: const TextStyle(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Nút Back
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
