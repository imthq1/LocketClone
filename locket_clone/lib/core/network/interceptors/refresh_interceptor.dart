import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';
import '../../config/app_env.dart';
import '../../storage/secure_storage.dart';

class RefreshInterceptor extends Interceptor {
  final SecureStorage _storage;
  final Dio _dio;

  /// _refreshingFuture dùng như một "mutex" đơn giản:
  /// - Nếu đang refresh, các request khác chờ _refreshingFuture hoàn thành rồi retry.
  Future<void>? _refreshingFuture;

  RefreshInterceptor(this._storage, this._dio);

  bool _isRefreshCall(RequestOptions o) {
    return o.path.endsWith('/auth/refresh');
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final shouldTryRefresh =
        err.response?.statusCode == 401 && !_isRefreshCall(err.requestOptions);

    if (!shouldTryRefresh) {
      return handler.next(err);
    }

    try {
      // Nếu đang có một refresh chạy rồi => đợi nó xong.
      if (_refreshingFuture != null) {
        await _refreshingFuture;
      } else {
        // Tự khởi động refresh và gán vào _refreshingFuture
        _refreshingFuture = _doRefresh();
        await _refreshingFuture;
      }

      // Refresh xong (thành công) => retry request gốc với AT mới.
      final newResponse = await _retryWithNewToken(err.requestOptions);
      return handler.resolve(newResponse);
    } catch (e) {
      // Refresh thất bại => xoá token và trả lỗi để UI điều hướng Login.
      await _storage.deleteAccessToken();
      return handler.next(err);
    } finally {
      _refreshingFuture = null;
    }
  }

  /// Gọi POST /auth/refresh để lấy accessToken mới và lưu lại.
  Future<void> _doRefresh() async {
    final res = await _dio.post('/auth/refresh');

    // 1) Chuẩn hoá raw -> Map<String, dynamic>
    dynamic raw = res.data;
    if (raw is String) {
      try {
        raw = jsonDecode(raw);
      } catch (_) {
        throw DioException(
          requestOptions: res.requestOptions,
          response: res,
          error: 'Phản hồi refresh không phải JSON hợp lệ',
          type: DioExceptionType.badResponse,
        );
      }
    }
    if (raw is! Map<String, dynamic>) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        error: 'Định dạng phản hồi refresh không hợp lệ',
        type: DioExceptionType.badResponse,
      );
    }

    // final Map<String, dynamic> payload = (raw['data'] is Map<String, dynamic>)
    //     ? raw['data'] as Map<String, dynamic>
    //     : raw;

    final Map<String, dynamic> payload = raw['data'] as Map<String, dynamic>;

    // const candidates = [
    //   'accessToken',
    //   'access_token',
    //   'token',
    //   'access',
    //   'jwt',
    //   'access-token',
    // ];

    String? newAT = payload['access_token'];

    // for (final k in candidates) {
    //   final v = payload[k];
    //   if (v is String && v.isNotEmpty) {
    //     newAT = v;
    //     break;
    //   }
    // }

    if (newAT == null || newAT.isEmpty) {
      throw DioException(
        requestOptions: res.requestOptions,
        response: res,
        error: 'Thiếu access token trong phản hồi refresh',
        type: DioExceptionType.badResponse,
      );
    }

    await _storage.writeAccessToken(newAT);
  }

  /// Retry request gốc với accessToken mới.
  Future<Response<dynamic>> _retryWithNewToken(
    RequestOptions requestOptions,
  ) async {
    final token = await _storage.readAccessToken();

    // Tạo options mới, giữ nguyên đa số cấu hình cũ
    final newOptions = Options(
      method: requestOptions.method,
      headers: {
        ...requestOptions.headers,
        if (token != null && token.isNotEmpty)
          AppEnv.authHeader: 'Bearer $token',
      },
      responseType: requestOptions.responseType,
      contentType: requestOptions.contentType,
      followRedirects: requestOptions.followRedirects,
      sendTimeout: requestOptions.sendTimeout,
      receiveTimeout: requestOptions.receiveTimeout,
      receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
      validateStatus: requestOptions.validateStatus,
      extra: requestOptions.extra,
    );

    return _dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: newOptions,
      cancelToken: requestOptions.cancelToken,
      onReceiveProgress: requestOptions.onReceiveProgress,
      onSendProgress: requestOptions.onSendProgress,
    );
  }
}
