import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _kAccessTokenKey = 'access_token';

  /// Khởi tạo storage mặc định.
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  /// Ghi Access Token vào secure storage.
  Future<void> writeAccessToken(String token) async {
    await _storage.write(key: _kAccessTokenKey, value: token);
  }

  /// Đọc Access Token từ secure storage.
  Future<String?> readAccessToken() async {
    return _storage.read(key: _kAccessTokenKey);
  }

  /// Xoá Access Token khi logout.
  Future<void> deleteAccessToken() async {
    await _storage.delete(key: _kAccessTokenKey);
  }
}
