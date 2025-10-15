class UserDTO {
  final int id;
  final String email;
  final String fullname;
  final String? address;
  final String? image;
  final String? roleName;
  final ListFriend? friend;

  const UserDTO({
    required this.id,
    required this.email,
    required this.fullname,
    this.address,
    this.image,
    this.roleName,
    this.friend,
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
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'fullname': fullname,
    'address': address,
    'image': image,
    'roleName': roleName,
    'friend': friend?.toJson(),
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
