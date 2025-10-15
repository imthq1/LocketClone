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
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthApi _api;
  final SecureStorage _storage;

  AuthRepositoryImpl(this._api, this._storage);

  @override
  Future<ResLoginDTO> login(String email, String password) async {
    // 1) Gọi API /auth/login để lấy accessToken và thông tin user cơ bản.
    final loginResponse = await _api.login(email: email, password: password);

    // 2) Lưu access token vào storage để các request sau sử dụng.
    await _storage.writeAccessToken(loginResponse.accessToken);

    // 3) Trả về toàn bộ đối tượng response.
    // Controller sẽ dùng thông tin này để cập nhật state tạm thời.
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
    // 1) Đăng ký tài khoản mới.
    await _api.register(
      email: email,
      password: password,
      fullname: fullname,
      address: address,
      imageUrl: imageUrl,
    );

    // 2) Đăng nhập ngay sau khi đăng ký thành công.
    return login(email, password);
  }

  @override
  Future<UserDTO> getCurrentUser() {
    // Vẫn giữ nguyên hàm này để AuthGate hoặc các nơi khác có thể gọi
    // để lấy thông tin user đầy đủ (bao gồm cả danh sách bạn bè).
    return _api.getAccount();
  }

  @override
  Future<void> logout() async {
    try {
      await _api.logout();
    } finally {
      // Dù server lỗi, vẫn xoá AT local để đảm bảo người dùng phải đăng nhập lại.
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
}