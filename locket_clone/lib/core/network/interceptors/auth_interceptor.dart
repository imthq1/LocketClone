import 'package:dio/dio.dart';
import '../../config/app_env.dart';
import '../../storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorage _storage;

  AuthInterceptor(this._storage);

  // Danh sách các endpoint không cần token.
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
    // Kiểm tra xem request có phải là public không.
    final isPublic = _publicPaths.any((p) => options.path.endsWith(p));

    if (isPublic) {
      options.headers.remove(AppEnv.authHeader);
    } else {
      try {
        final token = await _storage.readAccessToken();
        if (token != null && token.isNotEmpty) {
          options.headers[AppEnv.authHeader] = 'Bearer $token';
        }
      } catch (e) {
        // Bỏ qua nếu có lỗi đọc storage, không chặn request.
      }
    }

    // Tiếp tục gửi request đi.
    handler.next(options);
  }
}
