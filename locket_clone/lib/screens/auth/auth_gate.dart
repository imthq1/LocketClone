import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:locket_clone/screens/home/home_screen.dart';
import 'package:locket_clone/screens/welcome/welcome_screen.dart';
import 'package:locket_clone/services/application/auth_controller.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _requested = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_requested) {
      _requested = true;
      // Khi app start, thử loadCurrentUser
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AuthController>().loadCurrentUser();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (_, auth, __) {
        if (auth.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (auth.user == null) {
          // Chưa đăng nhập -> vào màn hình welcome
          return WelcomeScreen(
            onSignUp: () => Navigator.pushNamed(context, '/register'),
            onSignIn: () => Navigator.pushNamed(context, '/login'),
          );
        }

        // Đã có user -> Home
        return const HomeScreen();
      },
    );
  }
}