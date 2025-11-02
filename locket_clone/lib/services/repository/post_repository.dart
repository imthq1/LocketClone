import 'package:locket_clone/services/data/datasources/post_api.dart';
import 'package:locket_clone/services/data/models/post_dto.dart';

abstract class PostRepository {
  Future<String> uploadImage(String filePath, {String folder});
  Future<PostDTO> createPost(PostCreateDTO dto);
  Future<FeedPageDTO> getFeed({int page, int size});

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
    final publicId = await uploadImage(filePath, folder: folder);
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
