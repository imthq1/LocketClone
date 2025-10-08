class UserLogin {
  final int id;
  final String email;
  final String fullname;

  const UserLogin({
    required this.id,
    required this.email,
    required this.fullname,
  });

  /// - Thử nhiều tên key khác nhau (id/userId/uid, fullname/fullName/name, ...)
  /// - Nếu thiếu trường bắt buộc → trả null (KHÔNG throw)
  static UserLogin? tryParse(Map<String, dynamic> m) {
    final idVal = _pickNum(m, const ['id', 'userId', 'uid', 'ID']);
    final emailVal = _pickStr(m, const ['email', 'mail', 'userEmail']);
    final nameVal = _pickStr(m, const [
      'fullname',
      'fullName',
      'name',
      'displayName',
    ]);

    if (idVal == null || emailVal == null || nameVal == null) {
      return null; // không đủ thông tin -> bỏ qua
    }
    return UserLogin(id: idVal.toInt(), email: emailVal, fullname: nameVal);
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    'fullname': fullname,
  };

  // --- helpers ---
  static num? _pickNum(Map<String, dynamic> m, List<String> keys) {
    for (final k in keys) {
      final v = m[k];
      if (v is num) return v;
      if (v is String) {
        final parsed = num.tryParse(v);
        if (parsed != null) return parsed;
      }
    }
    return null;
  }

  static String? _pickStr(Map<String, dynamic> m, List<String> keys) {
    for (final k in keys) {
      final v = m[k];
      if (v is String && v.isNotEmpty) return v;
    }
    return null;
  }
}

class ResLoginDTO {
  final String accessToken;
  final UserLogin? userLogin; // optional

  const ResLoginDTO({required this.accessToken, this.userLogin});

  /// Dùng khi BẠN ĐÃ unwrap "data" ở tầng API (tức đối số là map bên trong "data")
  factory ResLoginDTO.fromJson(Map<String, dynamic> json) {
    final token = _pickToken(json);
    if (token == null) {
      // Token là bắt buộc để tiếp tục luồng; thiếu -> throw
      throw const FormatException('Thiếu accessToken trong phản hồi');
    }

    final userObj = _pickUserObj(json); // có thể null
    final ul = (userObj == null) ? null : UserLogin.tryParse(userObj);

    return ResLoginDTO(accessToken: token, userLogin: ul);
  }

  /// Dùng khi bạn truyền payload GỐC (có thể có lớp "data").
  /// Ví dụ: { "message": "...", "data": { "access_token": "...", "userLogin": {...} } }
  factory ResLoginDTO.fromBackend(Map<String, dynamic> raw) {
    final inner = (raw['data'] is Map<String, dynamic>)
        ? raw['data'] as Map<String, dynamic>
        : raw;
    return ResLoginDTO.fromJson(inner);
  }

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    if (userLogin != null) 'userLogin': userLogin!.toJson(),
  };

  // ---- helpers ----

  /// Lấy token theo nhiều key phổ biến
  static String? _pickToken(Map<String, dynamic> m) {
    const candidates = [
      'access_token',
      'accessToken',
      'token',
      'access',
      'jwt',
      'access-token',
    ];
    for (final k in candidates) {
      final v = m[k];
      if (v is String && v.isNotEmpty) return v;
    }
    return null;
  }

  /// Tìm object user theo nhiều key (nếu có)
  static Map<String, dynamic>? _pickUserObj(Map<String, dynamic> m) {
    const userKeys = ['userLogin', 'user', 'account', 'userDTO', 'profile'];
    for (final k in userKeys) {
      final v = m[k];
      if (v is Map<String, dynamic>) return v;
    }
    return null;
  }
}
