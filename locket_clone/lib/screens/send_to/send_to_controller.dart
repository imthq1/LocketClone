import 'package:flutter/foundation.dart';
import 'package:locket_clone/services/application/auth_controller.dart';
import 'package:locket_clone/services/application/post_controller.dart';
import 'package:locket_clone/services/data/models/post_dto.dart';

class SendToController extends ChangeNotifier {
  final PostController _post;

  SendToController(AuthController auth, this._post);

  // --- Quản lý State ---
  String? _caption;
  bool _isSending = false;
  String? _error;

  // --- Getters cho UI ---
  String? get caption => _caption;
  bool get isSending => _isSending;
  String? get error => _error;

  void setCaption(String? newCaption) {
    _caption = newCaption;
    notifyListeners();
  }

  Future<bool> sendPost(String imagePath) async {
    if (_isSending) return false;

    _isSending = true;
    _error = null;
    notifyListeners();

    const visibility = VisibilityEnum.friend;
    const List<int>? recipientIds = null;

    try {
      final created = await _post.sendPost(
        filePath: imagePath,
        caption: _caption ?? '',
        visibility: visibility,
        recipientIds: recipientIds,
      );

      if (created != null) {
        await _post.refresh();
        _isSending = false;
        notifyListeners();
        return true;
      } else {
        _error = _post.error ?? 'Gửi thất bại';
        _isSending = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      _isSending = false;
      notifyListeners();
      return false;
    }
  }
}
