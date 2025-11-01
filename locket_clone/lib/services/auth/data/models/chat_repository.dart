import 'package:locket_clone/services/auth/data/datasources/chat_api.dart';
import 'package:locket_clone/services/auth/data/models/chat_dto.dart';

abstract class ChatRepository {
  Future<ConversationDTO> getOrCreateConversation(String emailRq);

  Future<MessageDTO> sendMessage({
    required int conversationId,
    required int senderId,
    required String content,
    String? image,
  });
}

class ChatRepositoryImpl implements ChatRepository {
  final ChatApi _api;
  ChatRepositoryImpl(this._api);

  @override
  Future<ConversationDTO> getOrCreateConversation(String emailRq) {
    return _api.getOrCreateConversation(emailRq);
  }

  @override
  Future<MessageDTO> sendMessage({
    required int conversationId,
    required int senderId,
    required String content,
    String? image,
  }) {
    return _api.sendMessage(
      conversationId: conversationId,
      senderId: senderId,
      content: content,
      image: image,
    );
  }
}
