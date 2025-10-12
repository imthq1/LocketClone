import 'package:locket_clone/services/auth/data/datasources/friend_api.dart';
import 'package:locket_clone/services/auth/data/models/user_dto.dart';

abstract class FriendRepository {
  Future<List<UserDTO>> getFriends();
}

class FriendRepositoryImpl implements FriendRepository {
  final FriendApi _api;
  FriendRepositoryImpl(this._api);

  @override
  Future<List<UserDTO>> getFriends() => _api.listFriends();
}
