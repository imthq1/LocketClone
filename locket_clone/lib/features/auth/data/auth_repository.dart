import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:locket_clone/core/network/http_client.dart';
import 'package:locket_clone/core/security/token_store.dart';
import 'package:locket_clone/core/models/login_models.dart';
import 'package:locket_clone/core/models/user_dto.dart';

class AuthRepository {
  static const String _host = String.fromEnvironment(
    'API_HOST',
    defaultValue: '10.0.2.2',
  );
  static const int _port = int.fromEnvironment('API_PORT', defaultValue: 8080);

  final http.Client _http = HttpClientPlatformImpl().client;
  final TokenStore _tokenStore = TokenStore();

  Uri _u(String path, [Map<String, String>? query]) =>
      Uri.http('$_host:$_port', path, query);

  Future<ResLoginDTO> login({
    required String email,
    required String password,
  }) async {
    final url = _u('/api/v1/auth/login');
    debugPrint('LOGIN URL = $url');
    try {
      final res = await _http
          .post(
            url,
            headers: const {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 15));

      if (res.statusCode != 200) {
        throw AuthException(_mapHttpError(res));
      }

      final raw = (jsonDecode(res.body) as Map).cast<String, dynamic>();
      final dto = ResLoginDTO.fromBackend(raw);
      await _tokenStore.saveAccessToken(dto.accessToken);
      return dto;
    } on SocketException {
      throw AuthException('Không thể kết nối máy chủ. Kiểm tra Wi-Fi/mạng.');
    } on HandshakeException {
      throw AuthException(
        'Lỗi chứng chỉ/HTTPS. Dùng HTTP hoặc cấu hình HTTPS đúng.',
      );
    } on TimeoutException {
      throw AuthException('Hết thời gian chờ. Máy chủ không phản hồi.');
    } on FormatException {
      throw AuthException('Phản hồi không phải JSON hợp lệ.');
    }
  }

  Future<bool> register({
    required String fullname,
    required String email,
    required String password,
    bool autoLogin = true, // tuỳ chọn: đăng nhập luôn sau khi đăng ký
  }) async {
    final url = _u('/api/v1/auth/register');
    final res = await _http.post(
      url,
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'email': email,
        'fullname': fullname,
        'password': password,
      }),
    );

    // Backend của bạn có thể trả 200 hoặc 201
    if (res.statusCode == 200 || res.statusCode == 201) {
      // Nhiều API register chỉ trả message, không trả token
      // Nếu backend của bạn trả giống login: {statusCode, data:{ userLogin, access_token }}
      // bạn có thể parse tương tự login để lưu token:
      try {
        final raw = jsonDecode(res.body);
        if (raw is Map &&
            raw['data'] is Map &&
            (raw['data'] as Map)['access_token'] != null) {
          final dto = ResLoginDTO.fromBackend(
            (raw as Map).cast<String, dynamic>(),
          );
          await _tokenStore.saveAccessToken(dto.accessToken);
          return true;
        }
      } catch (_) {
        /* im lặng nếu không phải format trên */
      }

      // Nếu không có token, tùy chọn autoLogin bằng email/password vừa tạo
      if (autoLogin) {
        await login(email: email, password: password);
      }
      return true;
    } else {
      throw AuthException(_mapHttpError(res));
    }
  }

  Future<UserDTO> getAccount() async {
    final token = await _tokenStore.getAccessToken();
    if (token == null || token.isEmpty) {
      throw AuthException('Missing access token');
    }
    final url = _u('/api/v1/auth/account');
    final res = await _http.get(
      url,
      headers: {'Accept': 'application/json', 'Authorization': 'Bearer $token'},
    );

    if (res.statusCode == 200) {
      final raw = jsonDecode(res.body) as Map<String, dynamic>;
      return UserDTO.fromBackend(raw);
    }
    if (res.statusCode == 401 || res.statusCode == 403) {
      throw AuthException('Token invalid/expired');
    }
    throw AuthException('getAccount failed: ${res.statusCode}');
  }
}

String _mapHttpError(http.Response res) {
  final status = res.statusCode;
  String? serverMsg;
  try {
    final data = jsonDecode(res.body);
    if (data is Map && data['message'] is String) {
      serverMsg = data['message'] as String;
    }
  } catch (_) {}
  switch (status) {
    case 400:
    case 401:
      return serverMsg ?? 'Email hoặc mật khẩu không đúng.';
    case 403:
      return serverMsg ?? 'Bạn không có quyền thực hiện hành động này.';
    case 404:
      return serverMsg ?? 'Không tìm thấy endpoint đăng nhập.';
    case 500:
      return serverMsg ?? 'Lỗi máy chủ. Vui lòng thử lại sau.';
    default:
      return 'Lỗi kết nối. Mã lỗi $status';
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);
  @override
  String toString() => message;
}
