/// Trước mỗi request, đọc Access Token (AT) từ SecureStorage
/// và đính vào header: Authorization: Bearer <AT>
/// Nếu chưa đăng nhập (chưa có AT) thì bỏ qua.

import 'package:dio/dio.dart';
import '../../config/app_env.dart';
import '../../storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorage _storage;

  AuthInterceptor(this._storage);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final token = await _storage.readAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers[AppEnv.authHeader] = 'Bearer $token';
      }
    } catch (_) {
      // Không chặn request nếu có lỗi đọc storage; cứ để đi tiếp.
    }
    handler.next(options);
  }
}