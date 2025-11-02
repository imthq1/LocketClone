class ResLoginDTO {
  final String accessToken;
  final UserLoginInfo userLogin;

  const ResLoginDTO({required this.accessToken, required this.userLogin});

  factory ResLoginDTO.fromJson(Map<String, dynamic> json) {
    final token = json['access_token'] as String?;
    if (token == null) {
      throw const FormatException('Phản hồi API Login thiếu "access_token"');
    }

    final userJson = json['userLogin'] as Map<String, dynamic>?;
    if (userJson == null) {
      throw const FormatException(
        'Phản hồi API Login thiếu đối tượng "userLogin"',
      );
    }

    return ResLoginDTO(
      accessToken: token,
      userLogin: UserLoginInfo.fromJson(userJson),
    );
  }
}

class UserLoginInfo {
  final int id;
  final String email;
  final String fullname;

  const UserLoginInfo({
    required this.id,
    required this.email,
    required this.fullname,
  });

  factory UserLoginInfo.fromJson(Map<String, dynamic> json) {
    return UserLoginInfo(
      id: (json['id'] as num).toInt(),
      email: json['email'] as String,
      fullname: json['name'] as String,
    );
  }
}
