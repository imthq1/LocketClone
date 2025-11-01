import 'package:flutter/foundation.dart';
import 'package:locket_clone/services/data/models/res_login_dto.dart';
import '../repository/auth_repository.dart';
import '../data/models/user_dto.dart';

class AuthController extends ChangeNotifier {
  final AuthRepository _repo;

  AuthController(this._repo);

  UserDTO? _user;
  ResLoginDTO? _loginDTO;
  bool _isLoading = false;
  String? _error;

  UserDTO? get user => _user;
  ResLoginDTO? get loginDTO => _loginDTO;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String? msg) {
    _error = msg;
    notifyListeners();
  }

  void _setUser(UserDTO? u) {
    _user = u;
    notifyListeners();
  }

  void _setResLogin(ResLoginDTO? res) {
    _loginDTO = res;
    notifyListeners();
  }

  /// Đăng nhập và cập nhật thông tin user cơ bản từ chính phản hồi của API login.
  /// Việc lấy thông tin đầy đủ (getCurrentUser) sẽ do AuthGate xử lý.
  Future<void> login(String email, String password) async {
    _setError(null);
    _setLoading(true);
    try {
      final loginRes = await _repo.login(email, password);
      _setResLogin(loginRes);

      // Đặt tạm user cơ bản (để UI có thể hiển thị nhanh)
      final userInfo = loginRes.userLogin;
      _setUser(
        UserDTO(
          id: userInfo.id,
          email: userInfo.email,
          fullname: userInfo.fullname,
        ),
      );

      // 👉 Sau khi login xong, load lại user đầy đủ từ backend
      await loadCurrentUser();
    } catch (e) {
      _setError(e.toString());
      _setUser(null);
    } finally {
      _setLoading(false);
    }
  }

  /// Đăng ký xong đăng nhập luôn.
  Future<void> registerThenLogin({
    required String email,
    required String password,
    required String fullname,
    String? address,
    String? imageUrl,
  }) async {
    _setError(null);
    _setLoading(true);
    try {
      final u = await _repo.registerThenLogin(
        email: email,
        password: password,
        fullname: fullname,
        address: address,
        imageUrl: imageUrl,
      );
      _setResLogin(u);

      // Tương tự hàm login, cập nhật user tạm thời
      final userInfo = u.userLogin;
      _setUser(
        UserDTO(
          id: userInfo.id,
          email: userInfo.email,
          fullname: userInfo.fullname,
        ),
      );
    } catch (e) {
      _setError(e.toString());
      _setUser(null);
    } finally {
      _setLoading(false);
    }
  }

  /// Khi mở app: AuthGate sẽ gọi hàm này.
  Future<void> loadCurrentUser() async {
    _setError(null);
    _setLoading(true);
    try {
      final hasAT = await _repo.hasAccessToken();
      if (!hasAT) {
        _setUser(null);
      } else {
        final u = await _repo.getCurrentUser();
        _setUser(u);
      }
    } catch (e) {
      _setUser(null);
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Đăng xuất.
  Future<void> logout() async {
    _setError(null);
    _setLoading(true);
    try {
      await _repo.logout();
      _setUser(null);
    } catch (e) {
      _setError(e.toString());
      _setUser(null);
    } finally {
      _setLoading(false);
    }
  }
}
