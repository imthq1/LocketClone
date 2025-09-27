import 'package:flutter/material.dart';
import '../../data/auth_repository.dart';
import 'package:flutter_application_1/core/models/user_dto.dart';
import 'package:flutter_application_1/routes/routes.dart';

class HomeGuard extends StatefulWidget {
  final Widget Function(BuildContext, UserDTO?) builder;

  /// Dùng builder để truyền UserDTO xuống HomeScreen nếu muốn hiển thị avatar/name.
  const HomeGuard({super.key, required this.builder});

  @override
  State<HomeGuard> createState() => _HomeGuardState();
}

class _HomeGuardState extends State<HomeGuard> with WidgetsBindingObserver {
  final _api = AuthRepository();
  UserDTO? _me;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _check();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _check(); // quay lại app thì kiểm tra lại
    }
  }

  Future<void> _check() async {
    setState(() => _loading = true);
    try {
      final me = await _api.getAccount();
      if (!mounted) return;
      setState(() {
        _me = me;
        _loading = false;
      });
    } on AuthException {
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.login, (r) => false);
    } catch (_) {
      if (!mounted) return;
      // Tuỳ bạn: có thể show SnackBar rồi về login, hoặc ở lại và retry.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không lấy được tài khoản.')),
      );
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.login, (r) => false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return widget.builder(context, _me);
  }
}
