import 'package:flutter/foundation.dart';
import 'package:locket_clone/services/repository/post_repository.dart';
import '../data/models/post_dto.dart';

class PostController extends ChangeNotifier {
  final PostRepository _repo;
  PostController(this._repo);

  bool _isSending = false;
  String? _error;
  PostDTO? _lastPost;

  bool get isSending => _isSending;
  String? get error => _error;
  PostDTO? get lastPost => _lastPost;
  final List<PostDTO> _items = [];
  bool _isLoading = false;
  bool _isLoadingMore = false;

  int _page = 0;
  int _totalPages = 1;
  int _size = 20;

  List<PostDTO> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get canLoadMore => _page + 1 < _totalPages;

  Future<void> load({int size = 20}) async {
    _error = null;
    _isLoading = true;
    _size = size;
    notifyListeners();

    try {
      final pageData = await _repo.getFeed(page: 0, size: _size);
      _page = pageData.page;
      _totalPages = pageData.totalPages;
      _items
        ..clear()
        ..addAll(pageData.data);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await load(size: _size);
  }

  Future<void> loadMore() async {
    if (!canLoadMore || _isLoadingMore) return;
    _isLoadingMore = true;
    notifyListeners();

    try {
      final nextPage = _page + 1;
      final pageData = await _repo.getFeed(page: nextPage, size: _size);
      _page = pageData.page;
      _totalPages = pageData.totalPages;
      _items.addAll(pageData.data);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void _setSending(bool v) {
    _isSending = v;
    notifyListeners();
  }

  void _setError(String? e) {
    _error = e;
    notifyListeners();
  }

  void _setLast(PostDTO? p) {
    _lastPost = p;
    notifyListeners();
  }

  /// Gửi post: upload ảnh -> tạo post
  Future<PostDTO?> sendPost({
    required String filePath,
    String caption = '',
    required VisibilityEnum visibility,
    List<int>? recipientIds,
    String folder = 'locket',
  }) async {
    _setError(null);
    _setSending(true);
    try {
      final created = await _repo.createFromFile(
        filePath: filePath,
        caption: caption,
        visibility: visibility,
        recipientIds: recipientIds,
        folder: folder,
      );
      _setLast(created);
      return created;
    } catch (e) {
      _setError(e.toString());
      return null;
    } finally {
      _setSending(false);
    }
  }
}
