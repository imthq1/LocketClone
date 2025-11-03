import 'package:flutter/foundation.dart';
import 'package:locket_clone/services/data/models/res_login_dto.dart';
import 'package:locket_clone/services/websocket/websocket_service.dart';
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

  String _getWsUrl() {
    return 'ws://10.0.2.2:8080/ws/websocket';
  }

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

  Future<void> login(String email, String password) async {
    _setError(null);
    _setLoading(true);
    try {
      final loginRes = await _repo.login(email, password);
      _setResLogin(loginRes);

      final userInfo = loginRes.userLogin;
      _setUser(
        UserDTO(
          id: userInfo.id,
          email: userInfo.email,
          fullname: userInfo.fullname,
        ),
      );

      WebSocketService.I.connect(url: _getWsUrl(), jwt: loginRes.accessToken);

      await loadCurrentUser();
    } catch (e) {
      _setError(e.toString());
      _setUser(null);
    } finally {
      _setLoading(false);
    }
  }

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

      final userInfo = u.userLogin;
      _setUser(
        UserDTO(
          id: userInfo.id,
          email: userInfo.email,
          fullname: userInfo.fullname,
        ),
      );

      WebSocketService.I.connect(url: _getWsUrl(), jwt: u.accessToken);
    } catch (e) {
      _setError(e.toString());
      _setUser(null);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadCurrentUser() async {
    _setError(null);
    _setLoading(true);
    try {
      final hasAT = await _repo.hasAccessToken();

      if (!hasAT) {
        _setUser(null);
        WebSocketService.I.disconnect();
      } else {
        final u = await _repo.getCurrentUser();
        _setUser(u);
        final token = await _repo.getSavedAccessToken();
        if (token != null && token.isNotEmpty) {
          WebSocketService.I.connect(url: _getWsUrl(), jwt: token);
        } else {
          WebSocketService.I.disconnect();
        }
      }
    } catch (e) {
      _setUser(null);
      _setError(e.toString());
      WebSocketService.I.disconnect();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setError(null);
    _setLoading(true);
    try {
      await _repo.logout();
      _setUser(null);
      WebSocketService.I.disconnect();
    } catch (e) {
      _setError(e.toString());
      _setUser(null);
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> sendResetOtp(String email) async {
    _setError(null);
    _setLoading(true);
    try {
      await _repo.sendResetOtp(email);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> verifyResetOtp(String email, String otp) async {
    _setError(null);
    _setLoading(true);
    try {
      await _repo.verifyResetOtp(email, otp);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    _setError(null);
    _setLoading(true);
    try {
      await _repo.resetPassword(email, newPassword);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateFullname(String newName) async {
    _setError(null);
    _setLoading(true);
    try {
      await _repo.updateFullname(newName);
      await loadCurrentUser();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    } finally {}
  }

  Future<bool> updateAvatar(String filePath) async {
    _setError(null);
    _setLoading(true);
    try {
      final publicId = await _repo.uploadAvatar(filePath, folder: 'avt');
      await _repo.updateAvatar(publicId);
      await loadCurrentUser();
      return true;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    } finally {}
  }
}
