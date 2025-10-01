import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStore {
  static const _kAccessToken = 'access_token';
  final _storage = const FlutterSecureStorage();

  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _kAccessToken, value: token);

  Future<String?> getAccessToken() => _storage.read(key: _kAccessToken);

  Future<void> clear() => _storage.delete(key: _kAccessToken);
}
