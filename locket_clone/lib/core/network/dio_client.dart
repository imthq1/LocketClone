/// Tạo một thể hiện Dio cấu hình sẵn:
/// - Base URL, headers JSON.
/// - Quản lý Cookie (mobile/desktop) để giữ refresh_token httpOnly.
/// - Web-aware: bật withCredentials để trình duyệt tự gửi cookie.
/// - Gắn 2 interceptors: AuthInterceptor (đính kèm AT), RefreshInterceptor (tự refresh khi 401).
///
/// LƯU Ý DEV LOCAL:
/// - Nếu backend set cookie [Secure; SameSite=None] trên HTTP, cookie sẽ không được gửi (đặc biệt trên web).
///   Giải pháp dev: dùng HTTPS hoặc tạm tắt `Secure` khi DEV.
/// - Trên Android, cần bật cleartext nếu dùng HTTP.

import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:path_provider/path_provider.dart';

import '../config/app_env.dart';
import '../storage/secure_storage.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/refresh_interceptor.dart';

class DioClient {
  DioClient._();

  /// Tạo một Dio đã cấu hình đầy đủ.
  /// - [storage]: để đọc/ghi access token trong interceptors.
  static Future<Dio> create(SecureStorage storage) async {
    final baseOptions = BaseOptions(
      baseUrl: AppEnv.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 20),
      headers: {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
    );

    final dio = Dio(baseOptions);

    // WEB: bật withCredentials để browser tự gửi cookie refresh_token (httpOnly).
    // (Chỉ hiệu lực trên web adapter của Dio.)
    if (kIsWeb) {
      dio.options.extra = {
        ...dio.options.extra,
        'withCredentials': true,
      };
    }

    // MOBILE/DESKTOP: gắn CookieManager để lưu và gửi lại cookie (refresh_token).
    // Lưu ý: Cookie có flag Secure sẽ chỉ được gửi qua HTTPS theo chuẩn.
    // Nếu backend dùng HTTP dev + Secure cookie, refresh có thể không chạy được.
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS || Platform.isMacOS || Platform.isLinux || Platform.isWindows)) {
      final supportDir = await getApplicationSupportDirectory();
      final jar = PersistCookieJar(storage: FileStorage('${supportDir.path}/.auth_cookies'));
      dio.interceptors.add(CookieManager(jar));
    }

    // Gắn AuthInterceptor: gắn Authorization: Bearer <AT> trước mỗi request.
    dio.interceptors.add(AuthInterceptor(storage));

    // Gắn RefreshInterceptor: nếu 401 → gọi /auth/refresh (dựa vào cookie RT) → lưu AT mới → retry request cũ.
    dio.interceptors.add(RefreshInterceptor(storage, dio));

    return dio;
  }
}