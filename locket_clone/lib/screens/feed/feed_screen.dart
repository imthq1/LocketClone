import 'package:flutter/material.dart';
import 'package:locket_clone/screens/feed/widgets/feed_bottom_bar.dart';
import 'package:locket_clone/screens/feed/widgets/friend_feed_post_page.dart';
import 'package:locket_clone/screens/feed/widgets/my_feed_post_page.dart';
import 'package:locket_clone/services/application/auth_controller.dart';
import 'package:locket_clone/services/application/post_controller.dart';
import 'package:locket_clone/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:locket_clone/services/data/models/post_dto.dart';
import 'package:locket_clone/shared/cloudinary_helper.dart';

class FeedScreen extends StatefulWidget {
  final VoidCallback? onBackToCamera;

  const FeedScreen({super.key, this.onBackToCamera});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  bool _isGridView = false;
  final PageController _feedPageController = PageController();

  @override
  void dispose() {
    _feedPageController.dispose();
    super.dispose();
  }

  Future<void> _refreshFeed(BuildContext context) {
    return context.read<PostController>().refresh();
  }

  void _toggleViewMode() {
    setState(() {
      _isGridView = !_isGridView;
    });
  }

  void _onGridItemTapped(int index) {
    setState(() {
      _isGridView = false;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_feedPageController.hasClients) {
        _feedPageController.jumpToPage(index);
      }
    });
  }

  Widget _buildPageView(List<PostDTO> allPosts, int? myId) {
    return PageView.builder(
      controller: _feedPageController,
      scrollDirection: Axis.vertical,
      itemCount: allPosts.length,
      itemBuilder: (context, index) {
        final post = allPosts[index];
        final bool isMyPost = (myId != null && post.authorId == myId);

        if (isMyPost) {
          return MyFeedPostPage(post: post);
        } else {
          return FriendFeedPostPage(post: post);
        }
      },
    );
  }

  Widget _buildGridView(List<PostDTO> allPosts) {
    return GridView.builder(
      padding: const EdgeInsets.only(top: 70, left: 2, right: 2, bottom: 150),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Số cột
        crossAxisSpacing: 6, // Khoảng cách cột
        mainAxisSpacing: 6, // Khoảng cách hàng ngang
        childAspectRatio: 1.0, // Hình vuông
      ),
      itemCount: allPosts.length,
      itemBuilder: (context, index) {
        final post = allPosts[index];

        return _GridPostItem(
          post: post,
          onTap: () {
            _onGridItemTapped(index);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final postCtrl = context.watch<PostController>();
    final myId = context.watch<AuthController>().user?.id;
    final allPosts = postCtrl.items;

    Widget feedContent;

    if (postCtrl.isLoading && allPosts.isEmpty) {
      feedContent = const Center(
        child: CircularProgressIndicator(color: AppColors.brandYellow),
      );
    } else if (allPosts.isEmpty) {
      feedContent = ListView(
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          const Center(
            child: Text(
              'Không có bài đăng nào.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      );
    } else {
      if (_isGridView) {
        feedContent = _buildGridView(allPosts);
      } else {
        feedContent = _buildPageView(allPosts, myId);
      }
    }

    final refreshableFeed = RefreshIndicator(
      onRefresh: () => _refreshFeed(context),
      color: AppColors.brandYellow,
      backgroundColor: AppColors.background,
      child: feedContent,
    );

    return Stack(
      children: [
        refreshableFeed,
        Align(
          alignment: Alignment.bottomCenter,
          child: FeedBottomBar(
            onGridPressed: _toggleViewMode,
            onShutterPressed: widget.onBackToCamera,
          ),
        ),
      ],
    );
  }
}

class _GridPostItem extends StatelessWidget {
  final PostDTO post;
  final VoidCallback? onTap;

  const _GridPostItem({required this.post, this.onTap});

  @override
  Widget build(BuildContext context) {
    final imageUrl = buildCloudinaryUrl(post.image);

    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          color: AppColors.fieldBackground,
          child: imageUrl.isEmpty
              ? const Icon(Icons.image_not_supported, color: AppColors.textHint)
              : Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.textPrimary,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.error_outline,
                      color: AppColors.textHint,
                    );
                  },
                ),
        ),
      ),
    );
  }
}
