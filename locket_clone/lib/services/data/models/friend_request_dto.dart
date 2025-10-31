class FriendRequestItemDTO {
  final int requestId;
  final int requesterId;
  final String requesterEmail;
  final String requesterFullname;
  final String requesterAvatar;
  final String status;

  FriendRequestItemDTO({
    required this.requestId,
    required this.requesterId,
    required this.requesterEmail,
    required this.requesterFullname,
    required this.requesterAvatar,
    required this.status,
  });

  factory FriendRequestItemDTO.fromJson(Map<String, dynamic> json) {
    return FriendRequestItemDTO(
      requestId: json['requestId'] as int,
      requesterId: json['requesterId'] as int,
      requesterEmail: json['requesterEmail'] as String,
      requesterFullname: json['requesterFullname'] as String,
      requesterAvatar: json['requesterAvatar']?.toString() ?? '',
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'requestId': requestId,
    'requesterId': requesterId,
    'requesterEmail': requesterEmail,
    'requesterFullname': requesterFullname,
    'requesterAvatar': requesterAvatar,
    'status': status,
  };
}
