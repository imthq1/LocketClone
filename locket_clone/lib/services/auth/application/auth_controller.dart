/// ChangeNotifier quản lý state xác thực:
/// - user: thông tin người dùng hiện tại
/// - isLoading: đang chạy API
/// - error: thông báo lỗi (nếu có)
///
/// Nhiệm vụ:
/// - login(email, password) -> cập nhật user, clear error
/// - registerThenLogin(...) -> đăng ký rồi đăng nhập, cập nhật user
/// - loadCurrentUser() -> khi vào app, nếu có AT thì gọi /account
/// - logout() -> gọi server + xoá AT, xoá user
///
/// Lưu ý:
/// - Tất cả lỗi từ Repository/Api đều bắt và đưa vào `error` dạng chuỗi thân thiện.
/// - Interceptor đã xử lý auto-refresh AT khi 401, nên controller không cần lo phần này.

import 'package:flutter/foundation.dart';
import 'package:locket_clone/services/auth/data/models/res_login_dto.dart';
import '../repository/auth_repository.dart';
import '../../auth/data/models/user_dto.dart';

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

  /// Đăng nhập → về Home nếu thành công (UI tự điều hướng khi user != null).
  Future<void> login(String email, String password) async {
    _setError(null);
    _setLoading(true);
    try {
      final u = await _repo.login(email, password);
      final f = await _repo.getCurrentUser();
      _setUser(f);
      print('u ${u}');
      _setResLogin(u);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Đăng ký xong đăng nhập luôn → về Home.
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
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Khi mở app: nếu có AT -> cố gắng lấy account; nếu hỏng, user = null.
  Future<void> loadCurrentUser() async {
    _setError(null);
    _setLoading(true);
    try {
      final hasAT = await _repo.hasAccessToken();
      if (!hasAT) {
        _setUser(null);
      } else {
        final u = await _repo.getCurrentUser();
        print(u.fullname);
        _setUser(u);
      }
    } catch (e) {
      // Có thể AT hết hạn + RT hết hạn -> /account 401 + refresh fail
      _setUser(null);
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Đăng xuất: revoke session + xoá AT local.
  Future<void> logout() async {
    _setError(null);
    _setLoading(true);
    try {
      await _repo.logout();
      _setUser(null);
    } catch (e) {
      // Dù server lỗi thì vẫn đã xoá AT local trong repository.
      _setError(e.toString());
      _setUser(null);
    } finally {
      _setLoading(false);
    }
  }
}
