/// Bao bọc flutter_secure_storage để lưu/lấy/xoá Access Token (AT).
/// Lý do:
/// - AT cần lưu an toàn (Keychain/iOS, EncryptedSharedPreferences/Android).
/// - Refresh Token (RT) là httpOnly cookie → FE không lưu/đọc trực tiếp.

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