/// Tầng Repository chịu trách nhiệm:
/// - Gọi AuthApi
/// - Lưu/Xoá Access Token vào SecureStorage
/// - Hợp nhất luồng "register -> login -> lấy account"
/// - Ẩn chi tiết gọi API khỏi controller/UI

import '../../../core/storage/secure_storage.dart';
import '../data/datasources/auth_api.dart';
import '../data/models/user_dto.dart';
import '../data/models/res_login_dto.dart';

abstract class AuthRepository {
  /// Đăng nhập: lưu AT, sau đó gọi /auth/account để lấy User đầy đủ.
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

  /// Kiểm tra có sẵn Access Token trong storage không.
  Future<bool> hasAccessToken();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthApi _api;
  final SecureStorage _storage;

  AuthRepositoryImpl(this._api, this._storage);

  @override
  Future<ResLoginDTO> login(String email, String password) async {
    // 1) Gọi /auth/login
    final res = await _api.login(email: email, password: password);
    print(res.userLogin?.email);
    // 2) Lưu access token để interceptor gắn vào các request sau
    await _storage.writeAccessToken(res.accessToken);

    // 3) Gọi /auth/account để lấy thông tin đầy đủ
    return res;
  }

  @override
  Future<ResLoginDTO> registerThenLogin({
    required String email,
    required String password,
    required String fullname,
    String? address,
    String? imageUrl,
  }) async {
    // 1) Đăng ký
    await _api.register(
      email: email,
      password: password,
      fullname: fullname,
      address: address,
      imageUrl: imageUrl,
    );

    // 2) Đăng nhập ngay sau khi đăng ký
    return login(email, password);
  }

  @override
  Future<UserDTO> getCurrentUser() async {
    return _api.getAccount();
  }

  @override
  Future<void> logout() async {
    try {
      await _api.logout();
    } finally {
      // Dù server có lỗi, vẫn xoá AT local để buộc user đăng nhập lại
      await _storage.deleteAccessToken();
      // Lưu ý: Cookie refresh_token sẽ do server clear (Set-Cookie Max-Age=0).
      // Nếu muốn xoá cookie jar local (mobile/desktop), có thể làm ở nơi tạo Dio.
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
