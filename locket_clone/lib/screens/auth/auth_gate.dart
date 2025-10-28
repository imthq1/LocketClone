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
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final auth = context.read<AuthController>();

    final bool hasPartialUser = auth.user != null && auth.user!.friend == null;
    final bool needsFullLoad =
        (auth.user == null && !auth.isLoading) || hasPartialUser;

    if (needsFullLoad && !auth.isLoading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<AuthController>().loadCurrentUser();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (_, auth, __) {
        final bool isEffectivelyLoading =
            auth.isLoading || (auth.user != null && auth.user!.friend == null);

        if (isEffectivelyLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (auth.user == null) {
          return WelcomeScreen(
            onSignUp: () => Navigator.pushNamed(context, '/register'),
            onSignIn: () => Navigator.pushNamed(context, '/login'),
          );
        }

        return const HomeScreen();
      },
    );
  }
}
