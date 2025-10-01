class FriendRequestReceived {
  final int requestId;
  final int requesterId;
  final String requesterEmail;
  final String requesterFullname;
  final String? requesterAvatar;
  final DateTime? createdAt;
  final String status;

  FriendRequestReceived({
    required this.requestId,
    required this.requesterId,
    required this.requesterEmail,
    required this.requesterFullname,
    this.requesterAvatar,
    this.createdAt,
    required this.status,
  });

  factory FriendRequestReceived.fromJson(Map<String, dynamic> j) {
    return FriendRequestReceived(
      requestId: (j['requestId'] as num).toInt(),
      requesterId: (j['requesterId'] as num).toInt(),
      requesterEmail: j['requesterEmail'] as String,
      requesterFullname: j['requesterFullname'] as String,
      requesterAvatar: j['requesterAvatar'] as String?,
      createdAt: j['createdAt'] != null
          ? DateTime.tryParse(j['createdAt'])
          : null,
      status: j['status'] as String? ?? 'pending',
    );
  }
}

class FriendRequestSent {
  final int requestId;
  final int targetUserId;
  final String targetEmail;
  final String targetFullname;
  final String? targetAvatar;
  final DateTime? createdAt;
  final String status;

  FriendRequestSent({
    required this.requestId,
    required this.targetUserId,
    required this.targetEmail,
    required this.targetFullname,
    this.targetAvatar,
    this.createdAt,
    required this.status,
  });

  factory FriendRequestSent.fromJson(Map<String, dynamic> j) {
    return FriendRequestSent(
      requestId: (j['requestId'] as num).toInt(),
      targetUserId: (j['targetUserId'] as num).toInt(),
      targetEmail: j['targetEmail'] as String,
      targetFullname: j['targetFullname'] as String,
      targetAvatar: j['targetAvatar'] as String?,
      createdAt: j['createdAt'] != null
          ? DateTime.tryParse(j['createdAt'])
          : null,
      status: j['status'] as String? ?? 'pending',
    );
  }
}

class PageMeta {
  final int size;
  final int number;
  final int totalElements;
  final int totalPages;

  PageMeta({
    required this.size,
    required this.number,
    required this.totalElements,
    required this.totalPages,
  });

  factory PageMeta.fromJson(Map<String, dynamic> j) => PageMeta(
    size: (j['size'] as num).toInt(),
    number: (j['number'] as num).toInt(),
    totalElements: (j['totalElements'] as num).toInt(),
    totalPages: (j['totalPages'] as num).toInt(),
  );
}

class PageResp<T> {
  final List<T> content;
  final PageMeta page;

  PageResp({required this.content, required this.page});

  static PageResp<T> fromJson<T>(
    Map<String, dynamic> j,
    T Function(Map<String, dynamic>) itemFromJson,
  ) {
    // JSON backend: { "content": [...], "page": {...} }
    final list = (j['content'] as List).cast<Map<String, dynamic>>();
    final meta = PageMeta.fromJson((j['page'] as Map).cast<String, dynamic>());
    return PageResp<T>(content: list.map(itemFromJson).toList(), page: meta);
  }
}
