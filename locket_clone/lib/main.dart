import 'package:flutter/material.dart';
import 'package:locket_clone/screens/friends/friends_screen.dart';
import 'package:locket_clone/screens/home/messages_screen.dart';
import 'package:locket_clone/screens/profile/profile_screen.dart';
import 'package:locket_clone/services/application/chat_controller.dart';
import 'package:locket_clone/services/application/friends_controller.dart';
import 'package:locket_clone/services/data/datasources/chat_api.dart';
import 'package:locket_clone/services/data/datasources/friend_api.dart';
import 'package:locket_clone/services/data/models/chat_repository.dart';
import 'package:locket_clone/services/repository/friend_repository.dart';
import 'package:locket_clone/services/repository/post_repository.dart';
import 'package:provider/provider.dart';

import 'core/storage/secure_storage.dart';
import 'core/network/dio_client.dart';
import 'services/data/datasources/auth_api.dart';
import 'services/repository/auth_repository.dart';
import 'services/application/auth_controller.dart';
import 'services/data/datasources/post_api.dart';
import 'services/application/post_controller.dart';
import 'screens/auth/auth_gate.dart';
import 'screens/home/home_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'package:locket_clone/screens/auth/otp_verification_screen.dart';
import 'package:locket_clone/screens/auth/create_password_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LocketClone());
}

class LocketClone extends StatelessWidget {
  const LocketClone({super.key});

  Future<
    ({
      AuthController auth,
      PostController post,
      FriendsController friend,
      ChatController chat,
    })
  >
  _initControllers() async {
    final storage = SecureStorage();
    final dio = await DioClient.create(storage);

    // Auth
    final authApi = AuthApi(dio);
    final authRepo = AuthRepositoryImpl(authApi, storage);
    final authCtrl = AuthController(authRepo);

    // Post
    final postApi = PostApi(dio);
    final postRepo = PostRepositoryImpl(postApi);
    final postCtrl = PostController(postRepo);

    //friend
    final friendApi = FriendApi(dio);
    final friendRepo = FriendRepositoryImpl(friendApi);
    final friendCtrl = FriendsController(friendRepo);

    final chatApi = ChatApi(dio);
    final chatRepo = ChatRepositoryImpl(chatApi);
    final chatCtrl = ChatController(chatRepo);

    return (auth: authCtrl, post: postCtrl, friend: friendCtrl, chat: chatCtrl);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<
      ({
        AuthController auth,
        PostController post,
        FriendsController friend,
        ChatController chat,
      })
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
            ChangeNotifierProvider<ChatController>.value(value: ctrls.chat),
          ],
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            home: const AuthGate(),
            routes: {
              '/home': (_) => const HomeScreen(),
              '/login': (_) => const LoginScreen(),
              '/register': (_) => const RegisterScreen(),
              '/chat': (_) => const MessagesScreen(),
              '/forgot-password': (_) => const ForgotPasswordScreen(),
              '/otp-verify': (_) => const OtpVerificationScreen(),
              '/reset-password': (_) => const CreatePasswordScreen(),
              '/register-step-2': (_) => const CreatePasswordScreen(),
              '/friends': (_) => const FriendsScreen(),
              '/profile': (_) => const ProfileScreen(),
            },
          ),
        );
      },
    );
  }
}
