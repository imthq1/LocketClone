class FriendRqSentItemDTO {
  final int requestId;
  final int targetUserId;
  final String targetEmail;
  final String targetFullname;
  final String? targetAvatar;
  final DateTime createdAt;

  const FriendRqSentItemDTO({
    required this.requestId,
    required this.targetUserId,
    required this.targetEmail,
    required this.targetFullname,
    required this.targetAvatar,
    required this.createdAt,
  });

  factory FriendRqSentItemDTO.fromJson(Map<String, dynamic> j) {
    return FriendRqSentItemDTO(
      requestId: j['requestId'] as int,
      targetUserId: j['targetUserId'] as int,
      targetEmail: j['targetEmail'] as String,
      targetFullname: j['targetFullname'] as String,
      targetAvatar: j['targetAvatar'] as String?,
      createdAt: DateTime.parse(j['createdAt'] as String),
    );
  }
}

class PageMetaDTO {
  final int size;
  final int number;
  final int totalElements;
  final int totalPages;

  const PageMetaDTO({
    required this.size,
    required this.number,
    required this.totalElements,
    required this.totalPages,
  });

  factory PageMetaDTO.fromJson(Map<String, dynamic> j) => PageMetaDTO(
    size: j['size'] as int,
    number: j['number'] as int,
    totalElements: j['totalElements'] as int,
    totalPages: j['totalPages'] as int,
  );
}

class FriendRqSentPageDTO {
  final List<FriendRqSentItemDTO> content;
  final PageMetaDTO page;

  const FriendRqSentPageDTO({required this.content, required this.page});

  factory FriendRqSentPageDTO.fromDataJson(Map<String, dynamic> data) {
    final list = (data['content'] as List<dynamic>)
        .map((e) => FriendRqSentItemDTO.fromJson(e as Map<String, dynamic>))
        .toList();
    final meta = PageMetaDTO.fromJson(data['page'] as Map<String, dynamic>);
    return FriendRqSentPageDTO(content: list, page: meta);
  }
}
