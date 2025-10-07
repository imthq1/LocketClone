class UserDTO {
  final int id;
  final String email;
  final String fullname;
  final String? address;
  final String? image;
  final String? roleName;

  const UserDTO({
    required this.id,
    required this.email,
    required this.fullname,
    this.address,
    this.image,
    this.roleName,
  });

  factory UserDTO.fromJson(Map<String, dynamic> json) => UserDTO(
    id: (json['id'] as num).toInt(),
    email: json['email'] as String,
    fullname: json['fullname'] as String,
    address: json['address'] as String?,
    image: json['image'] as String?,
    roleName: json['roleName'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'fullname': fullname,
    'address': address,
    'image': image,
    'roleName': roleName,
  };
}
