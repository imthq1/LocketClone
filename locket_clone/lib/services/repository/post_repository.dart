// lib/services/auth/data/repository/post_repository.dart
import 'package:locket_clone/services/data/datasources/post_api.dart';
import 'package:locket_clone/services/data/models/post_dto.dart';

abstract class PostRepository {
  Future<String> uploadImage(String filePath, {String folder});
  Future<PostDTO> createPost(PostCreateDTO dto);
  Future<FeedPageDTO> getFeed({int page, int size});

  /// Tiện ích: upload file rồi tạo post một lèo.
  Future<PostDTO> createFromFile({
    required String filePath,
    required String caption,
    required VisibilityEnum visibility,
    List<int>? recipientIds,
    String folder,
  });
}

class PostRepositoryImpl implements PostRepository {
  final PostApi _api;
  PostRepositoryImpl(this._api);

  @override
  Future<String> uploadImage(String filePath, {String folder = 'locket'}) {
    return _api.uploadImage(filePath: filePath, folder: folder);
  }

  @override
  Future<FeedPageDTO> getFeed({int page = 0, int size = 20}) {
    return _api.getFeed(page: page, size: size);
  }

  @override
  Future<PostDTO> createPost(PostCreateDTO dto) {
    return _api.createPost(dto);
  }

  @override
  Future<PostDTO> createFromFile({
    required String filePath,
    required String caption,
    required VisibilityEnum visibility,
    List<int>? recipientIds,
    String folder = 'locket',
  }) async {
    // 1) upload -> lấy public_id
    final publicId = await uploadImage(filePath, folder: folder);
    // 2) create -> gắn image = public_id
    return createPost(
      PostCreateDTO(
        caption: caption,
        image: publicId,
        visibility: visibility,
        recipientIds: recipientIds,
      ),
    );
  }
}
