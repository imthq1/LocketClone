import 'dart:convert';
import 'package:dio/dio.dart';
import '../models/post_dto.dart';

class ApiException implements Exception {
  final String message;
  final int? status;
  ApiException(this.message, {this.status});
  @override
  String toString() => 'ApiException($status): $message';
}

class PostApi {
  final Dio _dio;
  PostApi(this._dio);

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

  /// POST /upload/image  -> {"name": "...", "url": "locket/xxx"}
  Future<String> uploadImage({
    required String filePath,
    String folder = 'locket',
  }) async {
    try {
      final form = FormData.fromMap({
        'folder': folder,
        'file': await MultipartFile.fromFile(filePath),
      });
      final res = await _dio.post(
        '/upload/image',
        data: form,
        options: Options(contentType: 'multipart/form-data'),
      );
      final json = _unwrap(res.data);
      final publicId = json['url'] as String?;
      if (publicId == null || publicId.isEmpty) {
        throw ApiException('Upload thành công nhưng thiếu trường url');
      }
      return publicId;
    } on DioException catch (e) {
      throw _asApiException(e);
    }
  }

  /// POST /post
  Future<PostDTO> createPost(PostCreateDTO dto) async {
    try {
      final res = await _dio.post('/post', data: dto.toJson());
      // backend của bạn trả thẳng Post (không bọc data) -> _unwrap vẫn an toàn
      final json = _unwrap(res.data);
      return PostDTO.fromJson(json);
    } on DioException catch (e) {
      throw _asApiException(e);
    }
  }
}
