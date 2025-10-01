import 'package:flutter/material.dart';
import '../../data/auth_repository.dart';
import 'login_button.dart';
import '../../../../routes/routes.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _repo = AuthRepository();

  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      await _repo.login(
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      );

      if (!mounted) return;

      // ✅ Show trước
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đăng nhập thành công!')));

      // (tuỳ chọn) chờ một nhịp cho snackbar “búng” ra
      await Future.delayed(const Duration(milliseconds: 200));

      if (!mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.home, (route) => false);
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e, st) {
      // ✅ log để debug nếu còn lỗi khác
      debugPrint('[UI][LOGIN] $e\n$st');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Có lỗi xảy ra, vui lòng thử lại.')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goToSignUp() {
    // TODO: tạo màn /signup
    Navigator.of(context).pushNamed(AppRoutes.signup);
  }

  void _goToForgot() {
    // TODO: tạo màn /forgot-password
    // Navigator.of(context).pushNamed('/forgot-password');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Email
          TextFormField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'nhapemail@vd.com',
              prefixIcon: Icon(Icons.alternate_email),
              border: OutlineInputBorder(),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Vui lòng nhập email';
              final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
              if (!regex.hasMatch(v.trim())) return 'Email không hợp lệ';
              return null;
            },
          ),
          const SizedBox(height: 12),
          // Password
          TextFormField(
            controller: _passwordCtrl,
            obscureText: _obscure,
            autofillHints: const [AutofillHints.password],
            decoration: InputDecoration(
              labelText: 'Mật khẩu',
              hintText: '•••••••',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                tooltip: _obscure ? 'Hiện mật khẩu' : 'Ẩn mật khẩu',
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: Icon(
                  _obscure
                      ? Icons.visibility_rounded
                      : Icons.visibility_off_rounded,
                ),
              ),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Vui lòng nhập mật khẩu';
              if (v.length < 1) return 'Mật khẩu tối thiểu 1 ký tự';
              return null;
            },
            onFieldSubmitted: (_) => _loading ? null : _handleLogin(),
          ),

          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _goToForgot,
              child: const Text('Quên mật khẩu?'),
            ),
          ),
          const SizedBox(height: 8),

          // Nút Đăng nhập
          LoginButton(loading: _loading, onPressed: _handleLogin),

          const SizedBox(height: 14),
          _OrDivider(text: 'hoặc'),
          const SizedBox(height: 14),

          // Nút Đăng ký (viền gradient)
          _GradientBorderButton(
            onTap: _goToSignUp,
            child: const Text(
              'Tạo tài khoản mới',
              style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.2),
            ),
          ),

          const SizedBox(height: 10),
          // Link nhỏ
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            children: [
              Text(
                'Chưa có tài khoản?',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.75),
                ),
              ),
              GestureDetector(
                onTap: _goToSignUp,
                child: const Text(
                  'Đăng ký ngay',
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  final String text;
  const _OrDivider({required this.text});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(
      context,
    ).textTheme.bodySmall?.color?.withOpacity(0.6);
    return Row(
      children: [
        Expanded(child: Divider(color: color)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            text.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: color,
            ),
          ),
        ),
        Expanded(child: Divider(color: color)),
      ],
    );
  }
}

class _GradientBorderButton extends StatelessWidget {
  final VoidCallback? onTap;
  final Widget child;
  const _GradientBorderButton({required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        padding: const EdgeInsets.all(1.2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF7C3AED), Color(0xFF06B6D4)],
          ),
        ),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            color: isDark
                ? Colors.black.withOpacity(0.35)
                : Colors.white.withOpacity(0.85),
          ),
          child: child,
        ),
      ),
    );
  }
}
