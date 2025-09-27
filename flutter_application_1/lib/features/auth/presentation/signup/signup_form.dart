import 'package:flutter/material.dart';
import '../../data/auth_repository.dart';
import '../../../../routes/routes.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _repo = AuthRepository();

  bool _loading = false;
  bool _obscure = true;
  bool _agree = true; // giả định đã tick đồng ý điều khoản

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agree) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng đồng ý điều khoản sử dụng.')),
      );
      return;
    }
    setState(() => _loading = true);
    try {
      // Nếu bạn có API signup:
      await _repo.register(
        fullname: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
        autoLogin: true,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tạo tài khoản thành công!')),
      );
      // Điều hướng về Login hoặc vào app
      Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Có lỗi xảy ra, vui lòng thử lại.')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _goToLogin() {
    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Full name
          TextFormField(
            controller: _nameCtrl,
            textCapitalization: TextCapitalization.words,
            autofillHints: const [AutofillHints.name],
            decoration: const InputDecoration(
              labelText: 'Họ và tên',
              prefixIcon: Icon(Icons.person_outline_rounded),
              border: OutlineInputBorder(),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'Vui lòng nhập họ tên';
              if (v.trim().length < 2) return 'Họ tên quá ngắn';
              return null;
            },
          ),
          const SizedBox(height: 12),

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
            autofillHints: const [AutofillHints.newPassword],
            decoration: InputDecoration(
              labelText: 'Mật khẩu',
              hintText: 'Tối thiểu 6 ký tự',
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
            onFieldSubmitted: (_) => _loading ? null : _handleSignUp(),
          ),

          const SizedBox(height: 10),
          // Điều khoản (tuỳ chọn)
          Row(
            children: [
              Checkbox(
                value: _agree,
                onChanged: (v) => setState(() => _agree = v ?? false),
              ),
              Expanded(
                child: Text(
                  'Tôi đồng ý với Điều khoản & Chính sách bảo mật.',
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),
          // Nút Tạo tài khoản
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton(
              onPressed: _loading ? null : _handleSignUp,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2.4),
                    )
                  : const Text(
                      'Tạo tài khoản',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
            ),
          ),

          const SizedBox(height: 14),
          // Đường kẻ + link quay lại đăng nhập
          Row(
            children: [
              Expanded(
                child: Divider(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.4),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text('hoặc'),
              ),
              Expanded(
                child: Divider(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _goToLogin,
            child: const Text(
              'Đã có tài khoản? Đăng nhập',
              style: TextStyle(
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
