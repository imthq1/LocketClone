/// Khi server trả về 401 (Unauthorized) cho một request BẤT KỲ (trừ chính /auth/refresh),
/// ta sẽ:
///   1) Chạy refresh: POST /auth/refresh (cookie httpOnly 'refresh_token' sẽ được gửi tự động
///      bởi CookieManager (mobile/desktop) hoặc trình duyệt (web, nếu withCredentials + HTTPS).
///   2) Nếu refresh OK → lấy accessToken mới từ response, lưu vào SecureStorage.
///   3) Dùng accessToken mới để RE-TRY request gốc (giữ nguyên method/data/params).
///   4) Nếu refresh FAIL → trả lỗi 401 như cũ để UI quyết định (chuyển về Login).
///
/// Đồng bộ hoá: dùng mutex để tránh gọi refresh song song khi nhiều request cùng 401.

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
    // Path có thể là '/auth/refresh' hoặc '.../auth/refresh'
    return o.path.endsWith('/auth/refresh');
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final shouldTryRefresh =
        err.response?.statusCode == 401 && !_isRefreshCall(err.requestOptions);

    if (!shouldTryRefresh) {
      // Không phải 401, hoặc chính là call refresh → đẩy lỗi ra ngoài.
      return handler.next(err);
    }

    try {
      // Nếu đang có một refresh chạy rồi → đợi nó xong.
      if (_refreshingFuture != null) {
        await _refreshingFuture;
      } else {
        // Tự khởi động refresh và gán vào _refreshingFuture
        _refreshingFuture = _doRefresh();
        await _refreshingFuture;
      }

      // Refresh xong (thành công) → retry request gốc với AT mới.
      final newResponse = await _retryWithNewToken(err.requestOptions);
      return handler.resolve(newResponse);
    } catch (e) {
      // Refresh thất bại → xoá token (phòng hờ) và trả lỗi để UI điều hướng Login.
      await _storage.deleteAccessToken();
      return handler.next(err);
    } finally {
      // Bất kể thành/bại, reset mutex để lần sau còn chạy lại.
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

    final Map<String, dynamic> payload = (raw['data'] is Map<String, dynamic>)
        ? raw['data'] as Map<String, dynamic>
        : raw;

    const candidates = [
      'accessToken',
      'access_token',
      'token',
      'access',
      'jwt',
      'access-token',
    ];
    String? newAT;
    for (final k in candidates) {
      final v = payload[k];
      if (v is String && v.isNotEmpty) {
        newAT = v;
        break;
      }
    }

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
