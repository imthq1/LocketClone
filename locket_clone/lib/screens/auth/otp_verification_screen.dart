import 'package:flutter/material.dart';
import 'package:locket_clone/theme/app_colors.dart';
import 'package:locket_clone/screens/auth/widgets/primary_auth_button.dart';
import 'package:locket_clone/screens/auth/widgets/primary_auth_input.dart';

class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});
  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpCtl = TextEditingController();
  bool _isContinueEnabled = false;
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _otpCtl.addListener(_validateInput);
  }

  @override
  void dispose() {
    _otpCtl.removeListener(_validateInput);
    _otpCtl.dispose();
    super.dispose();
  }

  /// Chỉ bật nút khi nhập đủ 6 chữ số
  void _validateInput() {
    final otp = _otpCtl.text.trim();
    final bool isEnabled = otp.length == 6;
    if (isEnabled != _isContinueEnabled) {
      setState(() {
        _isContinueEnabled = isEnabled;
      });
    }
  }

  /// Lấy email được truyền từ màn hình "Quên mật khẩu"
  String? _getEmailArg() {
    try {
      return ModalRoute.of(context)!.settings.arguments as String?;
    } catch (e) {
      return null;
    }
  }

  /// Xử lý khi nhấn nút "Xác nhận"
  Future<void> _submit() async {
    if (!_isContinueEnabled) return;
    setState(() => _isLoading = true);

    final email = _getEmailArg();
    final otp = _otpCtl.text.trim();

    // TODO: Triển khai gọi API xác thực OTP
    // await context.read<AuthController>().verifyOtp(email, otp);

    // Giả lập một cuộc gọi API
    await Future.delayed(const Duration(seconds: 1));
    final bool isOtpValid = true; // Giả sử OTP luôn đúng

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (isOtpValid) {
      // Chuyển đến màn hình Đặt lại mật khẩu, mang theo email và OTP đã xác thực
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/reset-password',
        (route) => route.isFirst, // Giữ lại màn hình Welcome/Login
        arguments: {'email': email, 'otp': otp},
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Mã OTP không hợp lệ. Vui lòng thử lại.'),
          backgroundColor: AppColors.error.withOpacity(0.9),
        ),
      );
    }
  }

  /// Xử lý khi nhấn "Gửi lại mã"
  Future<void> _resendOtp() async {
    setState(() => _isResending = true);
    final email = _getEmailArg();

    // TODO: Gọi API gửi lại mã
    // await context.read<AuthController>().resendOtp(email);

    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _isResending = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã gửi lại mã tới $email'),
        backgroundColor: AppColors.success.withValues(alpha: 0.9),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final email = _getEmailArg();

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
                            // Image.asset(
                            //   'lib/assets/locket_app_icon.png',
                            //   height: 64,
                            //   width: 64,
                            // ),
                            // const SizedBox(height: 16),
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
                              label: 'Xác nhận',
                              isLoading: _isLoading,
                              onPressed: _isContinueEnabled ? _submit : null,
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: _isLoading || _isResending
                                  ? null
                                  : _resendOtp,
                              child: Text(
                                _isResending ? 'Đang gửi...' : 'Gửi lại mã',
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
