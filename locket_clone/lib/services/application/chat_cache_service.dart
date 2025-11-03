import 'package:flutter/foundation.dart';
import 'package:locket_clone/services/application/chat_controller.dart';
import 'package:locket_clone/services/repository/chat_repository.dart';
import 'package:locket_clone/services/websocket/websocket_service.dart';

/// Lưu lại tin nhắn nháp và lịch sử cuộn
class ChatCacheService extends ChangeNotifier {
  final ChatRepository _repo;
  ChatCacheService(this._repo);

  // Dùng email của đối phương làm "key"
  final Map<String, ChatController> _controllers = {};

  ChatController getController(String partnerEmail) {
    // Nếu chưa có, tạo mới và lưu vào cache
    if (!_controllers.containsKey(partnerEmail)) {
      final newController = ChatController(_repo, WebSocketService.I)
        ..loadConversationByEmail(partnerEmail);
      _controllers[partnerEmail] = newController;
    }
    // Trả về controller từ cache
    return _controllers[partnerEmail]!;
  }

  /// Xóa cache
  void clearAll() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    _controllers.clear();
    notifyListeners();
  }
}
