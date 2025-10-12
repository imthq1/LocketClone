import 'package:flutter/foundation.dart';
import 'package:locket_clone/services/auth/repository/post_repository.dart';
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
