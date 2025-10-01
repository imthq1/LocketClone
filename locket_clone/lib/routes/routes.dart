import 'package:flutter/material.dart';
import 'package:locket_clone/features/auth/presentation/login/login_screen.dart';
import 'package:locket_clone/features/auth/presentation/home/home_screen.dart';
import 'package:locket_clone/features/auth/presentation/signup/signup_screen.dart';
import 'package:locket_clone/features/auth/presentation/home/home_guard.dart';

class AppRoutes {
  // (tuỳ chọn) static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home';

  static final Map<String, WidgetBuilder> routes = {
    // (tuỳ chọn) splash: (_) => const AuthGate(),
    login: (_) => const LoginScreen(),
    signup: (_) => const SignUpScreen(),
    home: (ctx) => HomeGuard(builder: (ctx, me) => HomeScreen(me: me)),
  };
}
