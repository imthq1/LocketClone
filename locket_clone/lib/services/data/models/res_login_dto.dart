/// Data Transfer Object cho phản hồi từ API /auth/login.
class ResLoginDTO {
  final String accessToken;
  final UserLoginInfo userLogin;

  const ResLoginDTO({
    required this.accessToken,
    required this.userLogin,
  });

  /// Factory constructor để tạo một instance `ResLoginDTO` từ một Map (JSON).
  /// Hàm này được gọi sau khi đã "unwrap" lớp `data` từ phản hồi API.
  factory ResLoginDTO.fromJson(Map<String, dynamic> json) {
    // Lấy access token từ key 'access_token'.
    // Nếu không có, sẽ throw lỗi vì đây là trường bắt buộc.
    final token = json['access_token'] as String?;
    if (token == null) {
      throw const FormatException('Phản hồi API Login thiếu "access_token"');
    }

    // Lấy đối tượng userLogin.
    // Nếu không có, cũng throw lỗi.
    final userJson = json['userLogin'] as Map<String, dynamic>?;
    if (userJson == null) {
      throw const FormatException('Phản hồi API Login thiếu đối tượng "userLogin"');
    }

    return ResLoginDTO(
      accessToken: token,
      userLogin: UserLoginInfo.fromJson(userJson),
    );
  }
}

/// Chứa thông tin cơ bản của người dùng trả về khi đăng nhập thành công.
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