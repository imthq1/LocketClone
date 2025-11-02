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

    // if (kIsWeb) {
    //   dio.options.extra = {...dio.options.extra, 'withCredentials': true};
    // }

    if (!kIsWeb) {
      final supportDir = await getApplicationSupportDirectory();
      final jar = PersistCookieJar(
        storage: FileStorage('${supportDir.path}/.auth_cookies'),
      );
      dio.interceptors.add(CookieManager(jar));
    }

    // Gắn AuthInterceptor: gắn Authorization: Bearer <AT> trước mỗi request.
    dio.interceptors.add(AuthInterceptor(storage));

    // Gắn RefreshInterceptor: nếu 401 → gọi /auth/refresh (dựa vào cookie RT) → lưu AT mới → retry request cũ.
    dio.interceptors.add(RefreshInterceptor(storage, dio));

    return dio;
  }
}
