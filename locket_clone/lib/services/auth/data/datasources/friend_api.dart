import 'dart:convert';
import 'package:dio/dio.dart';
import '../../../auth/data/models/user_dto.dart';
import '../../data/models/friend_request_dto.dart';
import '../../data/models/friend_request_sent_dto.dart';

class ApiException implements Exception {
  final String message;
  final int? status;
  ApiException(this.message, {this.status});
  @override
  String toString() => 'ApiException($status): $message';
}

class PageResult<T> {
  final List<T> content;
  final int size;
  final int number;
  final int totalElements;
  final int totalPages;

  PageResult({
    required this.content,
    required this.size,
    required this.number,
    required this.totalElements,
    required this.totalPages,
  });
}

class FriendApi {
  final Dio _dio;
  FriendApi(this._dio);

  Map<String, dynamic> _unwrap(dynamic raw) {
    dynamic decoded = raw;
    if (raw is String) {
      decoded = jsonDecode(raw);
    }
    if (decoded is Map<String, dynamic>) {
      if (decoded.containsKey('data')) {
        final data = decoded['data'];
        if (data is List) return {'list': data}; // cho các API trả List
        if (data is Map<String, dynamic>) return data; // cho các API trả Object
        return {'value': data}; // fallback
      }
      return decoded; // đã là payload cuối cùng
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

  Future<List<FriendRequestItemDTO>> listRequestByAddressee() async {
    try {
      final res = await _dio.get('/listRequestByAddressee');
      final json = _unwrap(res.data);
      final list = (json['list'] as List<dynamic>? ?? [])
          .map((e) => FriendRequestItemDTO.fromJson(e as Map<String, dynamic>))
          .toList();
      return list;
    } on DioException catch (e) {
      throw _asApiException(e);
    }
  }

  Future<UserDTO?> searchUserByEmail(String email) async {
    try {
      final res = await _dio.get(
        '/searchUser',
        queryParameters: {'email': email},
      );
      final data = _unwrap(res.data); // <-- giờ là Map của user
      return UserDTO.fromJson(data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      throw _asApiException(e);
    } catch (e) {
      // Bọc các lỗi parse khác (type cast, null, v.v.) cho dễ debug
      throw ApiException('Không đọc được dữ liệu người dùng: $e');
    }
  }

  Future<void> sendFriendRequest(int addresseeId) async {
    try {
      await _dio.post(
        '/sendFriendRq/$addresseeId',
        data: {'addresseeId': addresseeId},
      );
    } on DioException catch (e) {
      throw _asApiException(e);
    }
  }

  Future<FriendRqSentPageDTO> listRequestsSent({
    int page = 0,
    int size = 20,
  }) async {
    try {
      final res = await _dio.get(
        '/listFriendSend',
        queryParameters: {'page': page, 'size': size},
      );

      final data = res.data;
      if (data['statusCode'] != 200) {
        throw ApiException(
          data['error']?.toString() ?? 'Request failed',
          status: data['statusCode'],
        );
      }

      final dataObj = data['data'] as Map<String, dynamic>;
      return FriendRqSentPageDTO.fromDataJson(dataObj);
    } on DioException catch (e) {
      throw ApiException(
        e.response?.data?.toString() ?? e.message ?? 'Network error',
        status: e.response?.statusCode,
      );
    }
  }

  Future<void> acceptFriendRequest(String emailSender) async {
    try {
      await _dio.put(
        '/acceptFr',
        queryParameters: {'emailSender': emailSender},
      );
      // Backend trả 200 OK, không cần parse body
    } on DioException catch (e) {
      throw _asApiException(e);
    }
  }

  Future<void> deleteFriendRequestById(int id) async {
    try {
      await _dio.delete('/friendRq/$id');
    } on DioException catch (e) {
      throw _asApiException(e);
    }
  }

  Future<void> deleteFriendShip(int id) async {
    try {
      await _dio.delete('/friendShip/$id');
    } on DioException catch (e) {
      throw _asApiException(e);
    }
  }
}
