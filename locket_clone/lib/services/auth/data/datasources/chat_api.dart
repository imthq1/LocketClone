import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:locket_clone/services/auth/data/models/chat_dto.dart';
import 'package:locket_clone/services/data/datasources/auth_api.dart';

class ChatApi {
  final Dio _dio;
  ChatApi(this._dio);

  // ----- Helpers (giữ y hệt cách của AuthApi) -----
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

  Future<ConversationDTO> getOrCreateConversation(String emailRq) async {
    try {
      final res = await _dio.get(
        '/messageConversation',
        queryParameters: {'emailRq': emailRq},
      );
      final json = _unwrap(res.data);
      return ConversationDTO.fromJson(json);
    } on DioException catch (e) {
      throw _asApiException(e);
    }
  }

  Future<MessageDTO> sendMessage({
    required int conversationId,
    required int senderId,
    required String content,
    String? image,
  }) async {
    try {
      final body = {
        'conversationId': conversationId,
        'senderId': senderId,
        'content': content,
        if (image != null) 'image': image,
      };
      final res = await _dio.post('/message/send', data: body);
      final json = _unwrap(res.data);
      return MessageDTO.fromJson(json);
    } on DioException catch (e) {
      throw _asApiException(e);
    }
  }
}
