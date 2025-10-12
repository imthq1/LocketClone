import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../auth/data/models/user_dto.dart';

class ApiException implements Exception {
  final String message;
  final int? status;
  ApiException(this.message, {this.status});
  @override
  String toString() => 'ApiException($status): $message';
}

class FriendApi {
  final Dio _dio;
  FriendApi(this._dio);

  Map<String, dynamic> _unwrap(dynamic raw) {
    dynamic decoded = raw;
    if (raw is String) {
      try {
        decoded = jsonDecode(raw);
      } catch (_) {
        throw ApiException('Phản hồi không phải JSON hợp lệ');
      }
    }
    if (decoded is Map<String, dynamic>) {
      final maybeData = decoded['data'];
      if (maybeData != null) {
        // /listFr trả về data là List<dynamic>
        return {'list': maybeData};
      }
      return decoded;
    }
    throw ApiException('Định dạng phản hồi không hợp lệ');
  }

  ApiException _asApiException(DioException e) {
    final status = e.response?.statusCode;
    final data = e.response?.data;
    String? message;
    if (data is Map && data['message'] is String)
      message = data['message'] as String;
    else if (data is String && data.isNotEmpty)
      message = data;
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

  Future<List<UserDTO>> listFriends() async {
    try {
      final res = await _dio.get('/listFr');
      final json = _unwrap(res.data);
      final list = (json['list'] as List<dynamic>? ?? [])
          .map((e) => UserDTO.fromJson(e as Map<String, dynamic>))
          .toList();
      return list;
    } on DioException catch (e) {
      throw _asApiException(e);
    }
  }
}
