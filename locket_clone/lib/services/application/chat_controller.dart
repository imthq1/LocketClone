import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:locket_clone/services/data/models/chat_dto.dart';
import 'package:locket_clone/services/data/models/chat_repository.dart';

class ChatController extends ChangeNotifier {
  final ChatRepository _repo;
  ChatController(this._repo);

  bool isLoading = false;
  ConversationDTO? conversation;

  /// StreamController phát id của conversation hiện tại
  final StreamController<int?> _conversationIdCtrl =
      StreamController<int?>.broadcast();

  /// Stream để UI (ChatScreen) có thể listen
  Stream<int?> get conversationStream => _conversationIdCtrl.stream;

  /// Cập nhật conversation và emit id ra stream
  void _setConversation(ConversationDTO? conv) {
    conversation = conv;
    if (conv != null) {
      _conversationIdCtrl.add(conv.id);
    } else {
      _conversationIdCtrl.add(null);
    }
    notifyListeners();
  }

  /// Load conversation theo email đối phương
  Future<void> loadConversationByEmail(String email) async {
    isLoading = true;
    notifyListeners();
    try {
      final conv = await _repo.getOrCreateConversation(email);
      _setConversation(conv);
    } catch (e) {
      debugPrint('loadConversationByEmail error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Gửi tin nhắn REST fallback (nếu WS chưa kết nối)
  Future<void> sendMessage({
    required int senderId,
    required String content,
    String? image,
  }) async {
    if (conversation == null) return;
    final msg = await _repo.sendMessage(
      conversationId: conversation!.id,
      senderId: senderId,
      content: content,
      image: image,
    );

    // thêm tin nhắn mới vào conversation hiện tại
    final list = [...conversation!.messages, msg];
    conversation = conversation!.copyWith(messages: list);
    notifyListeners();
  }

  /// Khi WS nhận được tin mới → thêm vào danh sách
  void appendIncomingMessage(MessageDTO dto) {
    if (conversation == null) return;
    final list = [...conversation!.messages, dto];
    conversation = conversation!.copyWith(messages: list);
    notifyListeners();
  }

  @override
  void dispose() {
    _conversationIdCtrl.close();
    super.dispose();
  }
}
