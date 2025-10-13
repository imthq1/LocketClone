/// Trước mỗi request, đọc Access Token (AT) từ SecureStorage
/// và đính vào header: Authorization: Bearer <AT>
/// Nếu chưa đăng nhập (chưa có AT) thì bỏ qua.

import 'package:dio/dio.dart';
import '../../config/app_env.dart';
import '../../storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorage _storage;

  AuthInterceptor(this._storage);

  // Danh sách các endpoint không cần token
  static const _publicPaths = [
    '/auth/login',
    '/auth/register',
    '/auth/refresh',
    '/auth/forgot-password',
  ];

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Kiểm tra xem có phải request public không
      final isPublic = _publicPaths.any((p) => options.path.contains(p));

      if (!isPublic) {
        final token = await _storage.readAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers[AppEnv.authHeader] = 'Bearer $token';
        }
      } else {
        // Đảm bảo không có header Authorization cho request public
        options.headers.remove(AppEnv.authHeader);
      }
    } catch (e) {
      // Không chặn request nếu có lỗi đọc storage
    }

    handler.next(options);
  }
}
