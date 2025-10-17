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
  final String? content;
  final String? image; // public_id kiểu "abc" (nếu cần, tự build URL hiển thị)
  final bool read;
  final DateTime? createdAt;
  final ChatUserDTO? sender;

  const MessageDTO({
    required this.id,
    this.content,
    this.image,
    required this.read,
    this.createdAt,
    this.sender,
  });

  factory MessageDTO.fromJson(Map<String, dynamic> json) => MessageDTO(
    id: (json['id'] as num).toInt(),
    content: json['content'] as String?,
    image: json['image'] as String?,
    read: json['read'] as bool? ?? false,
    createdAt: json['createdAt'] is String
        ? DateTime.tryParse(json['createdAt'] as String)
        : null,
    sender: json['sender'] is Map<String, dynamic>
        ? ChatUserDTO.fromJson(json['sender'] as Map<String, dynamic>)
        : null,
  );
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
