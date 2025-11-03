import '../../core/storage/secure_storage.dart';
import '../data/datasources/auth_api.dart';
import '../data/models/user_dto.dart';
import '../data/models/res_login_dto.dart';

abstract class AuthRepository {
  Future<ResLoginDTO> login(String email, String password);
  Future<ResLoginDTO> registerThenLogin({
    required String email,
    required String password,
    required String fullname,
    String? address,
    String? imageUrl,
  });
  Future<UserDTO> getCurrentUser();
  Future<void> logout();
  Future<ResLoginDTO> refresh();
  Future<bool> hasAccessToken();
  Future<String?> getSavedAccessToken();
  Future<void> sendResetOtp(String email);
  Future<void> verifyResetOtp(String email, String otp);
  Future<void> resetPassword(String email, String newPassword);
  Future<String> uploadAvatar(String filePath, {String folder = 'avt'});
  Future<void> updateFullname(String newName);
  Future<void> updateAvatar(String publicId);
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthApi _api;
  final SecureStorage _storage;

  AuthRepositoryImpl(this._api, this._storage);

  @override
  Future<ResLoginDTO> login(String email, String password) async {
    final loginResponse = await _api.login(email: email, password: password);
    await _storage.writeAccessToken(loginResponse.accessToken);
    return loginResponse;
  }

  @override
  Future<ResLoginDTO> registerThenLogin({
    required String email,
    required String password,
    required String fullname,
    String? address,
    String? imageUrl,
  }) async {
    await _api.register(
      email: email,
      password: password,
      fullname: fullname,
      address: address,
      imageUrl: imageUrl,
    );
    return login(email, password);
  }

  @override
  Future<UserDTO> getCurrentUser() {
    return _api.getAccount();
  }

  @override
  Future<void> logout() async {
    try {
      await _api.logout();
    } finally {
      await _storage.deleteAccessToken();
    }
  }

  @override
  Future<ResLoginDTO> refresh() async {
    final res = await _api.refresh();
    await _storage.writeAccessToken(res.accessToken);
    return res;
  }

  @override
  Future<bool> hasAccessToken() async {
    final at = await _storage.readAccessToken();
    return at != null && at.isNotEmpty;
  }

  @override
  Future<String?> getSavedAccessToken() {
    return _storage.readAccessToken();
  }

  @override
  Future<void> sendResetOtp(String email) {
    return _api.sendResetOtp(email);
  }

  @override
  Future<void> verifyResetOtp(String email, String otp) {
    return _api.verifyResetOtp(email, otp);
  }

  @override
  Future<void> resetPassword(String email, String newPassword) {
    return _api.resetPassword(email, newPassword);
  }

  @override
  Future<String> uploadAvatar(String filePath, {String folder = 'avt'}) {
    return _api.uploadImage(filePath: filePath, folder: folder);
  }

  @override
  Future<void> updateFullname(String newName) {
    return _api.updateFullname(newName);
  }

  @override
  Future<void> updateAvatar(String publicId) {
    return _api.updateAvatar(publicId);
  }
}
