import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:locket_clone/services/data/models/chat_dto.dart';
import 'package:locket_clone/services/repository/chat_repository.dart';
import 'package:locket_clone/services/websocket/websocket_service.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class ChatController extends ChangeNotifier {
  final ChatRepository _repo;
  final WebSocketService _ws;
  ChatController(this._repo, this._ws);

  bool isLoading = false;
  ConversationDTO? conversation;
  String? _error;
  String? get error => _error;
  String draft = '';

  StompUnsubscribe? _convSub;
  StompUnsubscribe? _typingSub;
  bool _partnerTyping = false;
  bool get partnerTyping => _partnerTyping;
  Timer? _typingDebounce;

  void _setConversation(ConversationDTO? conv) {
    conversation = conv;
    notifyListeners();
  }

  // void _setError(String? msg) {
  //   _error = msg;
  //   notifyListeners();
  // }

  /// Load conversation qua REST, sau đó đăng ký topic qua WS
  Future<void> loadConversationByEmail(String email) async {
    isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final conv = await _repo.getOrCreateConversation(email);
      _setConversation(conv);
      _subscribeToTopics(); // Đăng ký topic sau khi load xong
    } catch (e) {
      _error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void _subscribeToTopics() {
    if (conversation == null || !_ws.isConnected) return;
    final convId = conversation!.id;

    _convSub?.call(); // Hủy sub cũ (nếu có)
    _typingSub?.call();

    // Lắng nghe tin nhắn mới
    _convSub = _ws.subscribeTopic(
      '/topic/conversations.$convId',
      _onMessageReceived,
    );

    // Lắng nghe sự kiện "đang gõ"
    _typingSub = _ws.subscribeTopic('/user/queue/typing', _onTypingReceived);
  }

  /// Xử lý khi nhận được tin nhắn mới
  void _onMessageReceived(Map<String, dynamic> json) {
    final msg = MessageDTO.fromJson(json);
    appendIncomingMessage(msg);
  }

  /// Xử lý khi nhận được sự kiện "đang gõ"
  void _onTypingReceived(Map<String, dynamic> json) {
    final cid = (json['conversationId'] as num?)?.toInt();
    // Chỉ quan tâm nếu đúng hội thoại này
    if (cid == conversation?.id) {
      final typing = json['typing'] == true;
      if (_partnerTyping == typing) return;

      _partnerTyping = typing;
      notifyListeners();

      // Tự động tắt "đang gõ" sau 5s nếu không nhận thêm event
      if (typing) {
        Future.delayed(const Duration(seconds: 5), () {
          if (_partnerTyping) {
            _partnerTyping = false;
            notifyListeners();
          }
        });
      }
    }
  }

  /// Gửi tin nhắn qua WebSocket
  void sendMessage({
    required int senderId,
    required String content,
    String? image,
  }) {
    if (conversation == null) {
      _error = "Chưa có hội thoại.";
      notifyListeners();
      return;
    }
    if (!_ws.isConnected) {
      _error = "Không thể gửi. Mất kết nối.";
      notifyListeners();
      return;
    }

    // Luôn gửi qua WebSocket
    _ws.send('/app/conversations/${conversation!.id}/send', {
      'senderId': senderId,
      'content': content,
      if (image != null) 'image': image,
    });
    notifyTyping(false); // Ngừng gõ sau khi gửi
  }

  /// Thông báo "đang gõ"
  void notifyTyping(bool isTyping) {
    _typingDebounce?.cancel();
    if (conversation == null || !_ws.isConnected) return;

    // Gửi ngay
    _ws.send('/app/conversations/${conversation!.id}/typing', {
      'typing': isTyping,
    });

    // Nếu đang gõ, tự động gửi "ngừng gõ" sau 3s
    if (isTyping) {
      _typingDebounce = Timer(const Duration(seconds: 3), () {
        if (conversation != null && _ws.isConnected) {
          _ws.send('/app/conversations/${conversation!.id}/typing', {
            'typing': false,
          });
        }
      });
    }
  }

  /// Thông báo "đã đọc"
  void sendReadEvent(int messageId) {
    if (conversation == null || !_ws.isConnected) return;
    _ws.send('/app/conversations/${conversation!.id}/read', {
      'messageId': messageId,
    });
  }

  /// Thêm tin nhắn (từ WS) vào danh sách
  void appendIncomingMessage(MessageDTO dto) {
    if (conversation == null) return;
    // Tránh thêm trùng lặp
    if (conversation!.messages.any((m) => m.id == dto.id)) return;

    final list = [...conversation!.messages, dto];
    conversation = conversation!.copyWith(messages: list);
    notifyListeners();
  }

  @override
  void dispose() {
    _convSub?.call();
    _typingSub?.call();
    _typingDebounce?.cancel();
    super.dispose();
  }
}
