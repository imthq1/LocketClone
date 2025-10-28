import 'package:flutter/material.dart';
import 'package:locket_clone/screens/feed/widgets/feed_bottom_bar.dart';
import 'package:locket_clone/screens/feed/widgets/friend_feed_post_page.dart';
import 'package:locket_clone/screens/feed/widgets/my_feed_post_page.dart';
import 'package:locket_clone/services/application/auth_controller.dart';
import 'package:locket_clone/services/application/post_controller.dart';
import 'package:locket_clone/theme/app_colors.dart';
import 'package:provider/provider.dart';

class FeedScreen extends StatelessWidget {
  final VoidCallback? onBackToCamera;

  const FeedScreen({super.key, this.onBackToCamera});

  Future<void> _refreshFeed(BuildContext context) {
    return context.read<PostController>().refresh();
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
      feedContent = PageView.builder(
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
            onGridPressed: () {
              // TODO: Xử lý mở Grid View (Loại 3)
            },
            onShutterPressed: onBackToCamera,
          ),
        ),
      ],
    );
  }
}
