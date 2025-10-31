import 'package:flutter/foundation.dart';
import 'package:locket_clone/services/application/auth_controller.dart';
import 'package:locket_clone/services/application/post_controller.dart';
import 'package:locket_clone/services/data/models/post_dto.dart';

class Recipient {
  final String id;
  final String name;
  final String? avatarUrl;
  final bool isAll;

  Recipient({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.isAll = false,
  });

  /// Hàm tiện ích để lấy chữ cái đầu
  String get initial {
    final t = name.trim();
    if (t.isEmpty) return 'U';
    return String.fromCharCodes(t.runes.take(1));
  }
}

/// Controller quản lý logic cho màn hình SendToScreen
class SendToController extends ChangeNotifier {
  final AuthController _auth;
  final PostController _post;

  SendToController(this._auth, this._post) {
    _loadRecipients();
  }

  // --- Quản lý State ---
  String? _caption;
  bool _isSending = false;
  String? _error;
  List<Recipient> _recipients = [];
  Set<String> _selectedIds = {'all'};

  // --- Getters cho UI ---
  String? get caption => _caption;
  bool get isSending => _isSending;
  String? get error => _error;
  List<Recipient> get recipients => List.unmodifiable(_recipients);
  Set<String> get selectedIds => Set.unmodifiable(_selectedIds);

  void _loadRecipients() {
    final listFriend = _auth.user?.friend;
    if (kDebugMode) {
      print('Danh sách bạn bè: ${listFriend?.sumUser} người');
    }
    final items = <Recipient>[
      Recipient(id: 'all', name: 'Tất cả', avatarUrl: null, isAll: true),
    ];

    if (listFriend != null && listFriend.friends.isNotEmpty) {
      items.addAll(
        listFriend.friends.map((u) {
          return Recipient(
            id: u.id.toString(),
            name: u.fullname,
            avatarUrl: u.image,
          );
        }),
      );
    }
    _recipients = items;
  }

  void setCaption(String? newCaption) {
    _caption = newCaption;
    notifyListeners();
  }

  void toggleRecipient(String id) {
    if (_isSending) return;

    if (id == 'all') {
      _selectedIds = {'all'};
    } else {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
      _selectedIds.remove('all');
      if (_selectedIds.isEmpty) {
        _selectedIds = {'all'};
      }
    }
    notifyListeners();
  }

  Future<bool> sendPost(String imagePath) async {
    if (_isSending) return false;

    _isSending = true;
    _error = null;
    notifyListeners();

    final visibility = _selectedIds.contains('all')
        ? VisibilityEnum.friend
        : VisibilityEnum.custom;

    final recipientIds = _selectedIds.contains('all')
        ? null
        : _selectedIds
              .where((id) => id != 'all')
              .map(int.tryParse)
              .whereType<int>()
              .toList();

    try {
      final created = await _post.sendPost(
        filePath: imagePath,
        caption: _caption ?? '',
        visibility: visibility,
        recipientIds: recipientIds,
      );

      if (created != null) {
        // Gửi xong, làm mới feed
        await _post.refresh();
        _isSending = false;
        notifyListeners();
        return true; // Thành công
      } else {
        _error = _post.error ?? 'Gửi thất bại';
        _isSending = false;
        notifyListeners();
        return false; // Thất bại
      }
    } catch (e) {
      _error = e.toString();
      _isSending = false;
      notifyListeners();
      return false; // Thất bại
    }
  }
}
