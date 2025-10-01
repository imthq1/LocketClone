class UserLogin {
  final int id;
  final String email;
  final String name; // backend dùng 'name'

  UserLogin({required this.id, required this.email, required this.name});

  factory UserLogin.fromJson(Map<String, dynamic> json) {
    return UserLogin(
      id: (json['id'] as num).toInt(),
      email: json['email'] as String,
      name: (json['name'] ?? json['fullname'] ?? '') as String,
    );
  }
}

class ResLoginDTO {
  final UserLogin userLogin;
  final String accessToken;

  ResLoginDTO({required this.userLogin, required this.accessToken});

  factory ResLoginDTO.fromBackend(Map<String, dynamic> raw) {
    // bóc lớp 'data'
    final data = (raw['data'] as Map).cast<String, dynamic>();

    // userLogin
    final userLogin = UserLogin.fromJson(
      (data['userLogin'] as Map).cast<String, dynamic>(),
    );

    // token tên 'access_token'
    final token = data['access_token'] as String;

    return ResLoginDTO(userLogin: userLogin, accessToken: token);
  }
}
