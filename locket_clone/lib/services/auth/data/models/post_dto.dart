enum VisibilityEnum { friend, custom, privates }

class PostCreateDTO {
  final String caption;
  final String image; // public_id kiểu "locket/xxx"
  final VisibilityEnum visibility;
  // optional: danh sách recipient nếu backend hỗ trợ
  final List<int>? recipientIds;

  const PostCreateDTO({
    required this.caption,
    required this.image,
    required this.visibility,
    this.recipientIds,
  });

  Map<String, dynamic> toJson() => {
    'caption': caption,
    'image': image,
    'visibility': visibility.name,
    if (recipientIds != null) 'recipientIds': recipientIds,
  };
}

class PostDTO {
  final int id;
  final String caption;
  final String image;
  final String visibility;
  final DateTime? createdAt;

  PostDTO({
    required this.id,
    required this.caption,
    required this.image,
    required this.visibility,
    this.createdAt,
  });

  factory PostDTO.fromJson(Map<String, dynamic> json) => PostDTO(
    id: (json['id'] as num).toInt(),
    caption: json['caption'] as String? ?? '',
    image: json['image'] as String? ?? '',
    visibility: json['visibility'] as String? ?? 'PUBLIC',
    createdAt: json['created_at'] != null
        ? DateTime.tryParse(json['created_at'] as String)
        : null,
  );
}
