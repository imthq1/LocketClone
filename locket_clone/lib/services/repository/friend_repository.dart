import 'package:locket_clone/services/data/datasources/friend_api.dart';
import 'package:locket_clone/services/data/models/user_dto.dart';
import '../data/models/friend_request_dto.dart';
import '../data/models/friend_request_sent_dto.dart';

abstract class FriendRepository {
  Future<List<UserDTO>> getFriends();
  Future<List<FriendRequestItemDTO>> getFriendRequests();

  /// Trả về null nếu không tìm thấy
  Future<UserDTO?> searchUser(String email);
  Future<void> sendFriendRequest(int addresseeId);
  Future<FriendRqSentPageDTO> getRequestsSent({int page, int size});
  Future<void> acceptFriendRequest(String email);
  Future<void> deleteFriendRequestById(int id);
  Future<void> deleteFriendShip(int id);
}

class FriendRepositoryImpl implements FriendRepository {
  final FriendApi _api;
  FriendRepositoryImpl(this._api);

  @override
  Future<List<UserDTO>> getFriends() => _api.listFriends();

  @override
  Future<List<FriendRequestItemDTO>> getFriendRequests() =>
      _api.listRequestByAddressee();

  @override
  Future<UserDTO?> searchUser(String email) => _api.searchUserByEmail(email);

  @override
  Future<void> sendFriendRequest(int addresseeId) =>
      _api.sendFriendRequest(addresseeId);

  @override
  Future<FriendRqSentPageDTO> getRequestsSent({int page = 0, int size = 20}) {
    return _api.listRequestsSent(page: page, size: size);
  }

  @override
  Future<void> acceptFriendRequest(String email) {
    return _api.acceptFriendRequest(email);
  }

  @override
  Future<void> deleteFriendRequestById(int id) {
    return _api.deleteFriendRequestById(id);
  }

  @override
  Future<void> deleteFriendShip(int id) {
    return _api.deleteFriendShip(id);
  }
}
