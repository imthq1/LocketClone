import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/storage/secure_storage.dart';
import 'core/network/dio_client.dart';
import 'services/auth/data/datasources/auth_api.dart';
import 'services/auth/repository/auth_repository.dart';
import 'services/auth/application/auth_controller.dart';

import 'screens/auth/auth_gate.dart';
import 'screens/home/home_screen.dart';
import 'screens/auth/login/login_screen.dart';
import 'screens/auth/register/register_screen.dart';
import 'screens/auth/register/create_username_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LocketClone());
}

class LocketClone extends StatelessWidget {
  const LocketClone({super.key});

  Future<AuthController> _initAuth() async {
    final storage = SecureStorage();
    final dio = await DioClient.create(storage);
    final api = AuthApi(dio);
    final repo = AuthRepositoryImpl(api, storage, dio);
    return AuthController(repo);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AuthController>(
      future: _initAuth(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }
        return ChangeNotifierProvider.value(
          value: snapshot.data!,
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: const AuthGate(),
            routes: {
              '/home': (_) => const HomeScreen(),
              '/login': (_) => const LoginScreen(),
              '/register': (_) => const RegisterScreen(),
            },
            onGenerateRoute: (settings) {
              if (settings.name == CreateUsernameScreen.route) {
                final args = settings.arguments;
                if (args is CreateUsernameArgs) {
                  return MaterialPageRoute(
                    builder: (_) => const CreateUsernameScreen(),
                    settings: RouteSettings(
                      name: CreateUsernameScreen.route,
                      arguments: args,
                    ),
                  );
                }
                return MaterialPageRoute(
                  builder: (_) => const Scaffold(
                    body: Center(
                      child: Text('Thiếu tham số cho CreateUsernameScreen'),
                    ),
                  ),
                );
              }
              return null;
            },
          ),
        );
      },
    );
  }
}
