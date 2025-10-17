import 'package:flutter/foundation.dart';
import 'package:locket_clone/services/data/models/chat_repository.dart';
import 'package:locket_clone/services/websocket/websocket_service.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import '../data/models/chat_dto.dart';

class ChatController extends ChangeNotifier {
  final ChatRepository _repo;
  ChatController(this._repo);

  ConversationDTO? _conversation;
  bool _isLoading = false;
  String? _error;
  StompUnsubscribe? _subscription;

  ConversationDTO? get conversation => _conversation;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }

  void _setError(String? msg) {
    _error = msg;
    notifyListeners();
  }

  void _setConversation(ConversationDTO? c) {
    _conversation = c;
    notifyListeners();
  }

  Future<void> loadConversationByEmail(String emailRq) async {
    _setError(null);
    _setLoading(true);
    try {
      final conv = await _repo.getOrCreateConversation(emailRq);
      _setConversation(conv);

      WebSocketService.I.connect(
        url: 'ws://10.0.2.2:8080/ws',
        onConnected: () {
          _subscribeTopic();
        },
        onError: (e, st) {
          _setError(e.toString());
        },
      );

      // Nếu đã connected sẵn → subscribe luôn
      if (WebSocketService.I.isConnected) {
        _subscribeTopic();
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void _subscribeTopic() {
    _subscription?.call();
    if (_conversation == null) return;

    final topic = '/topic/conversations.${_conversation!.id}';
    _subscription = WebSocketService.I.subscribeTopic(topic, (json) {
      final msg = MessageDTO.fromJson(json);
      final updated = ConversationDTO(
        id: _conversation!.id,
        createdAt: _conversation!.createdAt,
        updatedAt: DateTime.now(),
        user1: _conversation!.user1,
        user2: _conversation!.user2,
        messages: [..._conversation!.messages, msg],
      );
      _setConversation(updated);
    });
  }

  Future<void> sendMessage({
    required int senderId,
    required String content,
    String? image,
  }) async {
    if (_conversation == null) {
      _setError('Chưa có hội thoại.');
      return;
    }

    WebSocketService.I.send('/app/conversations/${_conversation!.id}/send', {
      'senderId': senderId,
      'content': content,
      'image': image,
    });
  }

  void disposeSocket() {
    _subscription?.call();
    _subscription = null;
  }
}
