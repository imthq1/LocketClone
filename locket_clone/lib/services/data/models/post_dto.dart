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

  final int? authorId;
  final String? authorEmail;
  final String? authorFullname;

  PostDTO({
    required this.id,
    required this.caption,
    required this.image,
    required this.visibility,
    this.createdAt,
    this.authorId,
    this.authorEmail,
    this.authorFullname,
  });

  factory PostDTO.fromJson(Map<String, dynamic> json) => PostDTO(
    id: (json['id'] as num).toInt(),
    caption: json['caption'] as String? ?? '',
    image: json['image'] as String? ?? '',
    visibility: json['visibility'] as String? ?? 'PUBLIC',
    createdAt: json['createdAt'] != null
        ? DateTime.tryParse(json['createdAt'] as String)
        : (json['created_at'] != null
              ? DateTime.tryParse(json['created_at'] as String)
              : null),
    authorId: (json['authorId'] is num)
        ? (json['authorId'] as num).toInt()
        : null,
    authorEmail: json['authorEmail'] as String,
    authorFullname: json['authorFullname'] as String?,
  );
}

class FeedPageDTO {
  final int size;
  final int page;
  final int totalPages;
  final int totalElements;
  final List<PostDTO> data;

  const FeedPageDTO({
    required this.size,
    required this.page,
    required this.totalPages,
    required this.totalElements,
    required this.data,
  });

  factory FeedPageDTO.fromJson(Map<String, dynamic> json) {
    final items = (json['data'] as List<dynamic>? ?? const [])
        .whereType<Map<String, dynamic>>()
        .map(PostDTO.fromJson)
        .toList();

    return FeedPageDTO(
      size: (json['size'] as num?)?.toInt() ?? items.length,
      page: (json['page'] as num?)?.toInt() ?? 0,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 1,
      totalElements: (json['totalElements'] as num?)?.toInt() ?? items.length,
      data: items,
    );
  }
}
