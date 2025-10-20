class ChatUserDTO {
  final int id;
  final String email;
  final String fullname;
  final String? imageUrl;

  const ChatUserDTO({
    required this.id,
    required this.email,
    required this.fullname,
    this.imageUrl,
  });

  factory ChatUserDTO.fromJson(Map<String, dynamic> json) => ChatUserDTO(
    id: (json['id'] as num).toInt(),
    email: json['email'] as String? ?? '',
    fullname: json['fullname'] as String? ?? '',
    imageUrl: json['imageUrl'] as String?,
  );
}

class MessageDTO {
  final int id;
  final ChatUserDTO? sender; // từ REST
  final int? senderId; // từ WS
  final String? content;
  final String? image;
  final bool? read;
  final DateTime? createdAt;

  MessageDTO({
    required this.id,
    this.sender,
    this.senderId,
    this.content,
    this.image,
    this.read,
    this.createdAt,
  });

  factory MessageDTO.fromJson(Map<String, dynamic> json) => MessageDTO(
    id: json['id'] as int,
    sender: json['sender'] != null
        ? ChatUserDTO.fromJson(json['sender'])
        : null,
    senderId: json['senderId'] as int?, // <-- lấy từ WS DTO
    content: json['content'] as String?,
    image: json['image'] as String?,
    read: json['read'] as bool?,
    createdAt: json['createdAt'] != null
        ? DateTime.parse(json['createdAt'] as String).toLocal()
        : null,
  );

  MessageDTO copyWith({
    int? id,
    ChatUserDTO? sender,
    int? senderId,
    String? content,
    String? image,
    bool? read,
    DateTime? createdAt,
  }) {
    return MessageDTO(
      id: id ?? this.id,
      sender: sender ?? this.sender,
      senderId: senderId ?? this.senderId,
      content: content ?? this.content,
      image: image ?? this.image,
      read: read ?? this.read,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class ConversationDTO {
  final int id;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final ChatUserDTO user1;
  final ChatUserDTO user2;
  final List<MessageDTO> messages;

  const ConversationDTO({
    required this.id,
    this.createdAt,
    this.updatedAt,
    required this.user1,
    required this.user2,
    required this.messages,
  });
  ConversationDTO copyWith({
    int? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    ChatUserDTO? user1,
    ChatUserDTO? user2,
    List<MessageDTO>? messages,
  }) {
    return ConversationDTO(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user1: user1 ?? this.user1,
      user2: user2 ?? this.user2,
      messages: (messages ?? this.messages),
    );
  }

  factory ConversationDTO.fromJson(Map<String, dynamic> json) =>
      ConversationDTO(
        id: (json['id'] as num).toInt(),
        createdAt: json['createdAt'] is String
            ? DateTime.tryParse(json['createdAt'] as String)
            : null,
        updatedAt: json['updatedAt'] is String
            ? DateTime.tryParse(json['updatedAt'] as String)
            : null,
        user1: ChatUserDTO.fromJson(json['user1'] as Map<String, dynamic>),
        user2: ChatUserDTO.fromJson(json['user2'] as Map<String, dynamic>),
        messages: (json['messages'] as List<dynamic>? ?? const [])
            .whereType<Map<String, dynamic>>()
            .map(MessageDTO.fromJson)
            .toList(),
      );
}
