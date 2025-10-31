import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:locket_clone/services/data/models/user_dto.dart';
import 'package:locket_clone/services/data/models/friend_request_dto.dart';
import 'package:locket_clone/services/repository/friend_repository.dart';
import '../data/models/friend_request_sent_dto.dart';

class FriendsController extends ChangeNotifier {
  final FriendRepository _repo;
  FriendsController(this._repo);

  // ====== STATE CHUNG ======
  bool _loading = false;
  String? _error;

  bool get isLoading => _loading;
  String? get error => _error;

  void _setLoading(bool v) {
    _loading = v;
    notifyListeners();
  }

  void _setError(String? e) {
    _error = e;
    notifyListeners();
  }

  // ====== BẠN BÈ ======
  List<UserDTO> _friends = [];
  List<UserDTO> get friends => _friends;
  int get friendsCount => _friends.length;

  void _setFriends(List<UserDTO> list) {
    _friends = list;
    notifyListeners();
  }

  // ====== LỜI MỜI KẾT BẠN (GỬI TỚI MÌNH) ======
  List<FriendRequestItemDTO> _incomingRequests = [];
  List<FriendRequestItemDTO> get incomingRequests => _incomingRequests;

  void _setIncomingRequests(List<FriendRequestItemDTO> list) {
    _incomingRequests = list;
    notifyListeners();
  }

  // ====== LỜI MỜI MÌNH ĐÃ GỬI (PENDING) ======
  List<FriendRqSentItemDTO> _sentRequests = [];
  List<FriendRqSentItemDTO> get sentRequests => _sentRequests;

  // Phân trang cơ bản
  int _sentPage = 0;
  bool _sentHasMore = true;
  bool _sentLoading = false;

  bool get isLoadingSent => _sentLoading;
  bool get hasMoreSent => _sentHasMore;

  bool _loaded = false;
  Future<void>? _ongoingLoad; // chống race khi nhiều nơi gọi cùng lúc
  bool get hasLoaded => _loaded;

  Future<void> loadOnce({bool force = false}) async {
    if (_loaded && !force) return;
    // nếu đang có 1 lần load khác → đợi nó xong
    if (_ongoingLoad != null) {
      await _ongoingLoad;
      return;
    }
    _ongoingLoad = load().whenComplete(() {
      _ongoingLoad = null;
    });
    await _ongoingLoad;
  }

  /// Load danh sách lời mời mình đã gửi (pending).
  /// - reset=true: load từ đầu, thay thế danh sách hiện tại
  /// - reset=false: load trang tiếp theo (nếu còn)
  Future<void> loadSent({bool reset = false, int size = 20}) async {
    if (_sentLoading) return;

    if (reset) {
      _sentPage = 0;
      _sentHasMore = true;
      _sentRequests = [];
      notifyListeners();
    }
    if (!_sentHasMore) return;

    _sentLoading = true;
    notifyListeners();

    try {
      final page = await _repo.getRequestsSent(page: _sentPage, size: size);

      if (reset) {
        _sentRequests = page.content;
      } else {
        _sentRequests = [..._sentRequests, ...page.content];
      }

      // cập nhật phân trang
      final totalPages = page.page.totalPages;
      _sentHasMore = (_sentPage + 1) < totalPages;
      _sentPage += 1;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _sentLoading = false;
      notifyListeners();
    }
  }

  // ====== SEARCH USER BY EMAIL ======
  Timer? _debounce;
  bool _searching = false;
  String _query = '';
  UserDTO? _searchResult;

  bool get isSearching => _searching;
  String get query => _query;
  UserDTO? get searchResult => _searchResult;
  bool get notFound =>
      _query.isNotEmpty && _searchResult == null && !_searching;

  void onQueryChanged(String q) {
    _query = q.trim();
    _searchResult = null;
    _searching = _query.isNotEmpty;
    notifyListeners();

    _debounce?.cancel();
    if (_query.isEmpty) {
      _searching = false;
      notifyListeners();
      return;
    }

    // snapshot để tránh race-condition khi gõ nhanh
    final snapshot = _query;

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        _searching = true;
        notifyListeners();

        final user = await _repo.searchUser(snapshot);

        if (_query != snapshot) return;

        _searchResult = user;
      } catch (_) {
        if (_query != snapshot) return;
        _searchResult = null;
      } finally {
        if (_query != snapshot) return;
        _searching = false;
        notifyListeners();
      }
    });
  }

  void clearSearch() {
    _debounce?.cancel();
    _query = '';
    _searchResult = null;
    _searching = false;
    notifyListeners();
  }

  // ====== SEND FRIEND REQUEST ======
  bool _sendingRequest = false;
  bool get isSendingRequest => _sendingRequest;

  /// Gửi lời mời kết bạn dựa trên user tìm được ở searchResult.
  /// Trả về true nếu gửi thành công (để UI hiển thị SnackBar).
  Future<bool> sendFriendRequestFromSearch() async {
    final target = _searchResult;
    if (target == null) return false;

    // Giả định UserDTO có field `id` là int (nếu tên khác, đổi lại cho đúng)
    final int? id = target.id;
    if (id == null) {
      _setError('Không tìm thấy ID người dùng.');
      return false;
    }

    _sendingRequest = true;
    _setError(null);
    notifyListeners();

    try {
      await _repo.sendFriendRequest(id);
      // Option: clear search sau khi gửi OK
      clearSearch();

      // Option: refresh danh sách lời mời/friends nếu backend có thay đổi
      // await refresh();

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _sendingRequest = false;
      notifyListeners();
    }
  }

  // ====== LOAD CHÍNH ======
  Future<void> load() async {
    _setError(null);
    _setLoading(true);
    try {
      // gọi song song: friends + incoming friend requests
      final results = await Future.wait([
        _repo.getFriends(),
        _repo.getFriendRequests(),
      ]);

      _setFriends(results[0] as List<UserDTO>);
      _setIncomingRequests(results[1] as List<FriendRequestItemDTO>);
      _loaded = true;
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  bool _accepting = false;
  bool get isAccepting => _accepting;

  /// ✅ Chấp nhận lời mời kết bạn
  Future<bool> acceptRequest(FriendRequestItemDTO item) async {
    final email = item.requesterEmail;
    if (email.isEmpty) return false;

    _accepting = true;
    _setError(null);
    notifyListeners();

    try {
      await _repo.acceptFriendRequest(email);

      // Xóa khỏi danh sách lời mời đến
      _incomingRequests.removeWhere((r) => r.requestId == item.requestId);

      // (Optional) refresh lại danh sách bạn bè
      await load();

      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    } finally {
      _accepting = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async => load();

  /// Từ chối lời mời gửi tới mình
  Future<bool> rejectIncoming(FriendRequestItemDTO item) async {
    try {
      await _repo.deleteFriendRequestById(item.requestId);
      _incomingRequests.removeWhere((r) => r.requestId == item.requestId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  /// Huỷ lời mời mình đã gửi
  Future<bool> cancelSent(int requestId) async {
    try {
      await _repo.deleteFriendRequestById(requestId);
      _sentRequests.removeWhere((r) => r.requestId == requestId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> unfriend(UserDTO other) async {
    final otherId = other.id;
    try {
      await _repo.deleteFriendShip(otherId);
      _friends.removeWhere((u) => u.id == otherId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
