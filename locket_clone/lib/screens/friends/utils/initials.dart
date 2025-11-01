// lib/features/friends/utils/initials.dart
/// Trả về 1–2 ký tự viết tắt từ tên/email.
/// - Rỗng => 'U'
/// - Email không có khoảng trắng => lấy 1–2 ký tự đầu của phần trước @
/// - Tên có khoảng trắng => lấy ký tự đầu của 2 từ đầu
String initialsFrom(String nameOrEmail, {int maxLetters = 2}) {
  final trimmed = nameOrEmail.trim();
  if (trimmed.isEmpty) return 'U';

  // Trường hợp giống email (không khoảng trắng, có '@')
  if (!trimmed.contains(' ') && trimmed.contains('@')) {
    final user = trimmed.split('@').first;
    if (user.isEmpty) return 'U';
    final take = user.length >= maxLetters ? maxLetters : 1;
    return user.substring(0, take).toUpperCase();
  }

  // Tên có khoảng trắng: lấy 2 ký tự đầu của 2 từ đầu
  final parts = trimmed
      .split(RegExp(r'\s+'))
      .where((e) => e.isNotEmpty)
      .toList();
  if (parts.isEmpty) return 'U';

  final letters = StringBuffer()
    ..write(parts[0][0])
    ..write(parts.length > 1 ? parts[1][0] : '');

  final s = letters.toString().toUpperCase();
  return s.isEmpty ? 'U' : s;
}
