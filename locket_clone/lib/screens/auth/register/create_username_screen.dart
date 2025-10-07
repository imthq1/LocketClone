import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:locket_clone/services/auth/application/auth_controller.dart';

class CreateUsernameArgs {
  final String email;
  final String password;
  const CreateUsernameArgs({required this.email, required this.password});
}

class CreateUsernameScreen extends StatefulWidget {
  static const route = '/create-username';
  const CreateUsernameScreen({super.key});

  @override
  State<CreateUsernameScreen> createState() => _CreateUsernameScreenState();
}

class _CreateUsernameScreenState extends State<CreateUsernameScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _fullNameCtl = TextEditingController();
  final TextEditingController _usernameCtl = TextEditingController();

  bool _submitting = false;
  CreateUsernameArgs? _args; // nhận từ ModalRoute.arguments

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Lấy arguments từ router (named route)
    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is CreateUsernameArgs) {
      _args = args;
    }
  }

  @override
  void dispose() {
    _fullNameCtl.dispose();
    _usernameCtl.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // Nếu thiếu args (điều hướng sai), báo và quay lại
    final args = _args;
    if (args == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thiếu tham số đăng ký (email/password).')),
      );
      Navigator.pop(context);
      return;
    }

    setState(() => _submitting = true);
    try {
      final auth = context.read<AuthController>();

      // Gọi registerThenLogin với email/password từ args + fullname từ đây.
      await auth.registerThenLogin(
        email: args.email.trim(),
        password: args.password.trim(),
        fullname: _fullNameCtl.text.trim(),
        // username: _usernameCtl.text.trim(), // sẽ dùng khi backend hỗ trợ
      );

      if (!mounted) return;
      if (auth.user != null) {
        // Navigator.pushReplacementNamed(context, HomeScreen.route);
        Navigator.pushReplacementNamed(context, '/home');
      } else if (auth.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(auth.error!)),
        );
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Khi đang submit hoặc AuthController đang running API
    final isBusy = _submitting || context.watch<AuthController>().isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Hoàn tất hồ sơ')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: AutofillGroup(
              child: Form(
                key: _formKey,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    const Text(
                      'Nhập thông tin cơ bản',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 16),

                    // FULL NAME
                    TextFormField(
                      controller: _fullNameCtl,
                      autofillHints: const [AutofillHints.name],
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Full Name *',
                        hintText: 'Ví dụ: Nguyễn Văn A',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Vui lòng nhập họ tên';
                        }
                        if (v.trim().length < 2) {
                          return 'Họ tên quá ngắn';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 12),

                    // USERNAME
                    TextFormField(
                      controller: _usernameCtl,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Username (tuỳ chọn)',
                        hintText: 'Ví dụ: nguyenvana',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isBusy ? null : _onSubmit,
                        child: isBusy
                            ? const SizedBox(
                                height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Tiếp tục'),
                      ),
                    ),

                    if (_args != null) ...[
                      const SizedBox(height: 8),
                      Text('Email: ${_args!.email}',
                          textAlign: TextAlign.center, style: const TextStyle(color: Colors.grey)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}