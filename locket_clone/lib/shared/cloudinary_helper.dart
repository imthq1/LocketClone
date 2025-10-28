const String kCloudName = 'dzf7ojogs';
const String kCloudBase = 'https://res.cloudinary.com/$kCloudName/image/upload/';

String buildCloudinaryUrl(String image) {
  if (image.isEmpty) return '';
  var id = image.trim();
  if (id.startsWith('/')) id = id.substring(1);
  final hasExt =
      id.contains('.') &&
      RegExp(r'\.(jpg|jpeg|png|webp|gif)$', caseSensitive: false).hasMatch(id);
  if (!hasExt) id = '$id.jpg';
  return '$kCloudBase$id';
}
