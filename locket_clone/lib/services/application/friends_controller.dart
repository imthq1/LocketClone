import 'package:flutter/foundation.dart';
import 'package:locket_clone/services/data/models/user_dto.dart';
import 'package:locket_clone/services/repository/friend_repository.dart';

class FriendsController extends ChangeNotifier {
  final FriendRepository _repo;
  FriendsController(this._repo);

  bool _loading = false;
  String? _error;
  List<UserDTO> _friends = [];

  bool get isLoading => _loading;
  String? get error => _error;
  List<UserDTO> get friends => _friends;

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void _setError(String? e) {
    _error = e;
    notifyListeners();
  }

  void _setList(List<UserDTO> l) {
    _friends = l;
    print('list Fr ${_friends}');
    notifyListeners();
  }

  Future<void> load() async {
    _setError(null);
    _setLoading(true);
    try {
      final list = await _repo.getFriends();
      _setList(list);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refresh() => load();
}
