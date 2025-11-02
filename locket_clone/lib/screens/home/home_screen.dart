import 'package:flutter/material.dart';
import 'package:locket_clone/screens/home/camera_view.dart';
import 'package:locket_clone/screens/feed/feed_screen.dart';
import 'package:locket_clone/screens/home/widgets/home_top_bar.dart';
import 'package:locket_clone/services/application/auth_controller.dart';
import 'package:locket_clone/services/application/post_controller.dart';
import 'package:locket_clone/theme/app_colors.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController(initialPage: 0);
  bool _feedLoaded = false;
  @override
  void initState() {
    super.initState();
    _pageController.addListener(_onPageChanged);
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageChanged);
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged() {
    if (_pageController.page?.round() == 1 && !_feedLoaded) {
      setState(() {
        _feedLoaded = true;
      });
      context.read<PostController>().load();
    }
  }

  void _scrollToFeed() {
    _pageController.animateToPage(
      1, // Trang Feed
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _scrollToCamera() {
    _pageController.animateToPage(
      0, // Trang Camera
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            PageView(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              children: [
                CameraView(onHistoryPressed: _scrollToFeed),
                FeedScreen(onBackToCamera: _scrollToCamera),
              ],
            ),
            Align(
              alignment: Alignment.topCenter,
              child: HomeTopBar(sumUser: user?.friend?.sumUser ?? 0),
            ),
          ],
        ),
      ),
    );
  }
}
