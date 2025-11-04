class UserDTO {
  final int id;
  final String email;
  final String fullname;
  final String? address;
  final String? image;
  final String? roleName;
  final ListFriend? friend;
  final LastMessageSummaryDTO? lastMessage;

  const UserDTO({
    required this.id,
    required this.email,
    required this.fullname,
    this.address,
    this.image,
    this.roleName,
    this.friend,
    this.lastMessage,
  });

  factory UserDTO.fromJson(Map<String, dynamic> json) => UserDTO(
    id: (json['id'] as num).toInt(),
    email: json['email'] as String,
    fullname: json['fullname'] as String,
    address: json['address'] as String?,
    image: json['image'] as String?,
    roleName: json['roleName'] as String?,
    friend: json['friend'] == null
        ? null
        : ListFriend.fromJson(json['friend'] as Map<String, dynamic>),
    lastMessage: json['lastMessage'] == null
        ? null
        : LastMessageSummaryDTO.fromJson(
            json['lastMessage'] as Map<String, dynamic>,
          ),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'fullname': fullname,
    'address': address,
    'image': image,
    'roleName': roleName,
    'friend': friend?.toJson(),
    'lastMessage': lastMessage?.toJson(),
  };
}

/// Khối "friend" trong JSON: {"sumUser": 1, "friends": [UserDTO,...]}
class ListFriend {
  final int sumUser;
  final List<UserDTO> friends;

  const ListFriend({required this.sumUser, required this.friends});

  factory ListFriend.fromJson(Map<String, dynamic> json) => ListFriend(
    sumUser: (json['sumUser'] as num).toInt(),
    friends: (json['friends'] as List<dynamic>? ?? [])
        .map((e) => UserDTO.fromJson(e as Map<String, dynamic>))
        .toList(),
  );

  Map<String, dynamic> toJson() => {
    'sumUser': sumUser,
    'friends': friends.map((e) => e.toJson()).toList(),
  };
}

class LastMessageSummaryDTO {
  final String? content;
  final DateTime? createdAt;
  final int? senderId;

  const LastMessageSummaryDTO({this.content, this.createdAt, this.senderId});

  factory LastMessageSummaryDTO.fromJson(Map<String, dynamic> json) =>
      LastMessageSummaryDTO(
        content: json['content'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String).toLocal()
            : null,
        senderId: (json['senderId'] as num?)?.toInt(),
      );

  Map<String, dynamic> toJson() => {
    'content': content,
    'createdAt': createdAt?.toIso8601String(),
    'senderId': senderId,
  };
}
