import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:locket_clone/services/auth/application/auth_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final email = TextEditingController();
  final pass = TextEditingController();
  bool loading = false;

  Future<void> _signin() async {
    setState(() => loading = true);
    try {
      final auth = context.read<AuthController>();
      await auth.login(email.text.trim(), pass.text.trim());

      if (!mounted) return;
      if (auth.user != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else if (auth.error != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(auth.error!)));
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _signup() {
    Navigator.pushReplacementNamed(context, '/register');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đăng nhập')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: email,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: pass,
              decoration: const InputDecoration(labelText: 'Mật khẩu'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            if (loading) const CircularProgressIndicator(),
            if (!loading)
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _signin,
                      child: const Text('Đăng nhập'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _signup,
                      child: const Text('Đăng ký'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
