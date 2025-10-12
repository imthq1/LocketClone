import 'package:flutter/material.dart';
import 'package:locket_clone/screens/home/messages_screen.dart';
import 'package:locket_clone/services/auth/application/friends_controller.dart';
import 'package:locket_clone/services/auth/data/datasources/friend_api.dart';
import 'package:locket_clone/services/auth/repository/friend_repository.dart';
import 'package:locket_clone/services/auth/repository/post_repository.dart';
import 'package:provider/provider.dart';

import 'core/storage/secure_storage.dart';
import 'core/network/dio_client.dart';
import 'services/auth/data/datasources/auth_api.dart';
import 'services/auth/repository/auth_repository.dart';
import 'services/auth/application/auth_controller.dart';

// >>> ADD: post layer imports
import 'services/auth/data/datasources/post_api.dart';

import 'services/auth/application/post_controller.dart';
// <<<

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

  // Khởi tạo cả AuthController và PostController dùng chung 1 Dio
  Future<({AuthController auth, PostController post, FriendsController friend})>
  _initControllers() async {
    final storage = SecureStorage();
    final dio = await DioClient.create(storage);

    // Auth
    final authApi = AuthApi(dio);
    final authRepo = AuthRepositoryImpl(
      authApi,
      storage,
    ); // giữ nguyên theo code bạn đang dùng
    final authCtrl = AuthController(authRepo);

    // Post
    final postApi = PostApi(dio);
    final postRepo = PostRepositoryImpl(postApi);
    final postCtrl = PostController(postRepo);

    //friend
    final friendApi = FriendApi(dio);
    final friendRepo = FriendRepositoryImpl(friendApi);
    final friendCtrl = FriendsController(friendRepo);

    return (auth: authCtrl, post: postCtrl, friend: friendCtrl);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<
      ({AuthController auth, PostController post, FriendsController friend})
    >(
      future: _initControllers(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }

        final ctrls = snapshot.data!;
        return MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthController>.value(value: ctrls.auth),
            ChangeNotifierProvider<PostController>.value(value: ctrls.post),
            ChangeNotifierProvider<FriendsController>.value(
              value: ctrls.friend,
            ),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: const AuthGate(),
            routes: {
              '/home': (_) => const HomeScreen(),
              '/login': (_) => const LoginScreen(),
              '/register': (_) => const RegisterScreen(),
              '/chat': (_) => const MessagesScreen(),
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
