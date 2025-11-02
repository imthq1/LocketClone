import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:locket_clone/services/data/models/user_dto.dart';
import 'package:locket_clone/services/data/models/friend_request_dto.dart';
import 'package:locket_clone/services/repository/friend_repository.dart';
import '../data/models/friend_request_sent_dto.dart';

enum RelationStatus { self, friend, outgoing, incoming, none }

class FriendsController extends ChangeNotifier {
  final FriendRepository _repo;
  FriendsController(this._repo, {int? meId, String? meEmail}) {
    _meId = meId;
    _meEmail = _normalizeEmail(meEmail);
  }

  int? _meId;
  String? _meEmail; // lowercase để so sánh
  void setMe({int? id, String? email}) {
    _meId = id;
    _meEmail = _normalizeEmail(email);
  }

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

    final tId = target.id;
    final tEmailNorm = _normalizeEmail(target.email);

    // Chặn gửi cho chính mình (dù UI có lỡ bật nút)
    if ((_meId != null && tId != null && tId == _meId) ||
        (_meEmail != null && _meEmail == tEmailNorm)) {
      _setError('Không thể kết bạn với chính mình.');
      notifyListeners();
      return false;
    }

    // Chỉ cho gửi khi chưa có quan hệ
    if (relationTo(target) != RelationStatus.none) {
      return false;
    }

    if (tId == null) {
      _setError('Không tìm thấy ID người dùng.');
      return false;
    }

    _sendingRequest = true;
    _setError(null);
    notifyListeners();

    try {
      await _repo.sendFriendRequest(tId);
      clearSearch();
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

  ///  Chấp nhận lời mời kết bạn
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

  Future<void> refresh() async {
    await Future.wait([
      load(), // bạn bè + lời mời gửi tới
      loadSent(reset: true), // reset & tải lại "lời mời bạn đã gửi"
    ]);
  }

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

  RelationStatus relationTo(UserDTO u) {
    final uId = u.id;
    final uEmailNorm = _normalizeEmail(u.email);

    // 1) Chính mình
    if ((_meId != null && uId != null && uId == _meId) ||
        (_meEmail != null && _meEmail == uEmailNorm)) {
      return RelationStatus.self;
    }

    // 2) Đã là bạn
    if (_friends.any(
      (f) =>
          (f.id != null && uId != null && f.id == uId) ||
          (_normalizeEmail(f.email) == uEmailNorm),
    )) {
      return RelationStatus.friend;
    }

    // 3) Họ đã gửi lời mời cho bạn (incoming)
    if (_incomingRequests.any(
      (r) =>
          (r.requesterId != null && uId != null && r.requesterId == uId) ||
          (_normalizeEmail(r.requesterEmail) == uEmailNorm),
    )) {
      return RelationStatus.incoming;
    }

    // 4) Bạn đã gửi lời mời cho họ (outgoing)
    if (_sentRequests.any((s) {
      final recvId = s.targetUserId; // đổi đúng theo DTO của bạn
      final recvEmailNorm = _normalizeEmail(s.targetEmail);
      return (recvId != null && uId != null && recvId == uId) ||
          (recvEmailNorm == uEmailNorm);
    })) {
      return RelationStatus.outgoing;
    }

    return RelationStatus.none;
  }

  // tiện cho UI: quan hệ của kết quả search hiện tại
  RelationStatus? get searchRelation =>
      (_searchResult == null) ? null : relationTo(_searchResult!);

  String _normalizeEmail(String? raw) {
    if (raw == null) return '';
    var s = raw.trim().toLowerCase();
    final at = s.indexOf('@');
    if (at <= 0) return s;

    var local = s.substring(0, at);
    var domain = s.substring(at + 1);

    if (domain == 'gmail.com') {
      final plus = local.indexOf('+');
      if (plus >= 0) local = local.substring(0, plus);
      local = local.replaceAll('.', '');
    }
    return '$local@$domain';
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
