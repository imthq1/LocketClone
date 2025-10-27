import 'package:flutter/material.dart';
import 'package:locket_clone/screens/feed/views/friend_feed_view.dart';
import 'package:locket_clone/screens/feed/views/my_feed_view.dart';
import 'package:locket_clone/screens/feed/widgets/feed_bottom_bar.dart';
import 'package:locket_clone/screens/feed/widgets/feed_page_switcher.dart';
import 'package:locket_clone/screens/home/widgets/home_top_bar.dart';
import 'package:locket_clone/theme/app_colors.dart';

class FeedScreen extends StatefulWidget {
  final VoidCallback? onBackToCamera;
  const FeedScreen({super.key, this.onBackToCamera});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final newPage = _pageController.page?.round() ?? 0;
      if (newPage != _currentPage) {
        setState(() {
          _currentPage = newPage;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onSwitchPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            // ------- Nội dung Feed (PageView Ngang) -------
            PageView(
              controller: _pageController,
              children: const [
                MyFeedView(), // Trang 0: Loại 1
                FriendFeedView(), // Trang 1: Loại 2
              ],
            ),

            // ------- Top Bar (Giữ nguyên) -------
            const Align(alignment: Alignment.topCenter, child: HomeTopBar()),

            // ------- Bộ chuyển trang (Mới) -------
            Align(
              alignment: Alignment.topCenter,
              child: FeedPageSwitcher(
                currentIndex: _currentPage,
                onPageChanged: _onSwitchPage,
              ),
            ),

            // ------- Bottom Bar (Giữ nguyên) -------
            Align(
              alignment: Alignment.bottomCenter,
              child: FeedBottomBar(
                onGridPressed: () {
                  // TODO: Chuyển sang Giao diện Loại 3 (Grid)
                },
                onShutterPressed: widget.onBackToCamera,
              ),
            ),
          ],
        ),
      ),
    );
  }
}