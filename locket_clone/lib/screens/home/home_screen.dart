import 'package:flutter/material.dart';
import 'package:locket_clone/screens/home/camera_view.dart';
import 'package:locket_clone/screens/home/friend_feed_view.dart';
import 'package:locket_clone/theme/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(initialPage: 0);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _scrollToFeed() {
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PageView(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        children: [
          CameraView(onHistoryPressed: _scrollToFeed),
          const FriendFeedView(),
        ],
      ),
    );
  }
}
