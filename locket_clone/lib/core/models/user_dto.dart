class UserDTO {
  final int id;
  final String email;
  final String fullname;
  final String? address;
  final String? image;
  final String? roleName;

  UserDTO({
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

  /// Factory parse từ response backend (có field `data`)
  factory UserDTO.fromBackend(Map<String, dynamic> raw) {
    final data = raw['data'];
    if (data is Map<String, dynamic>) {
      return UserDTO.fromJson(data);
    }
    throw FormatException('Invalid response format: missing data');
  }
}
