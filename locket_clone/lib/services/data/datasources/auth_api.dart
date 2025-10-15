import 'package:dio/dio.dart';
import 'dart:convert';
import '../models/user_dto.dart';
import '../models/res_login_dto.dart';

class ApiException implements Exception {
  final String message;
  final int? status;
  ApiException(this.message, {this.status});
  @override
  String toString() => 'ApiException($status): $message';
}

class AuthApi {
  final Dio _dio;
  AuthApi(this._dio);

  // ----- Helpers -----
  Map<String, dynamic> _unwrap(dynamic raw) {
    dynamic decoded = raw;
    if (raw is String) {
      try {
        decoded = jsonDecode(raw);
      } catch (_) {
        throw ApiException('Phản hồi không phải JSON hợp lệ');
      }
    }

    // 2) Nếu là Map -> unwrap data
    if (decoded is Map<String, dynamic>) {
      final maybeData = decoded['data'];
      if (maybeData is Map<String, dynamic>) return maybeData;
      return decoded;
    }

    throw ApiException(
      'Định dạng phản hồi không hợp lệ (không phải object JSON)',
    );
  }

  ApiException _asApiException(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    String? message;
    if (data is Map && data['message'] is String) {
      message = data['message'] as String;
    } else if (data is String && data.isNotEmpty) {
      message = data;
    }
    message ??= switch (e.type) {
      DioExceptionType.connectionTimeout => 'Kết nối server quá hạn.',
      DioExceptionType.sendTimeout => 'Gửi dữ liệu quá hạn.',
      DioExceptionType.receiveTimeout => 'Nhận dữ liệu quá hạn.',
      DioExceptionType.badResponse => 'Máy chủ trả về lỗi ($status).',
      DioExceptionType.cancel => 'Yêu cầu đã bị huỷ.',
      DioExceptionType.connectionError => 'Lỗi kết nối mạng.',
      _ => 'Đã xảy ra lỗi không xác định.',
    };
    return ApiException(message, status: status);
  }

  // ----- APIs -----

  Future<UserDTO> register({
    required String email,
    required String password,
    required String fullname,
    String? address,
    String? imageUrl,
  }) async {
    try {
      final body = <String, dynamic>{
        'email': email,
        'password': password,
        'fullname': fullname,
        if (address != null) 'address': address,
        if (imageUrl != null) 'imageUrl': imageUrl,
      };
      final res = await _dio.post('/auth/register', data: body);
      final json = _unwrap(res.data);
      return UserDTO.fromJson(json);
    } on DioException catch (e) {
      throw _asApiException(e);
    }
  }

  Future<ResLoginDTO> login({
    required String email,
    required String password,
  }) async {
    try {
      final res = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      final json = _unwrap(res.data);
      return ResLoginDTO.fromJson(json);
    } on DioException catch (e) {
      throw _asApiException(e);
    }
  }

  Future<UserDTO> getAccount() async {
    try {
      final res = await _dio.get('/auth/account');
      final json = _unwrap(res.data);
      return UserDTO.fromJson(json);
    } on DioException catch (e) {
      throw _asApiException(e);
    }
  }

  Future<ResLoginDTO> refresh() async {
    try {
      final res = await _dio.post('/auth/refresh');
      final json = _unwrap(res.data);
      return ResLoginDTO.fromJson(json);
    } on DioException catch (e) {
      throw _asApiException(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } on DioException catch (e) {
      throw _asApiException(e);
    }
  }
}
