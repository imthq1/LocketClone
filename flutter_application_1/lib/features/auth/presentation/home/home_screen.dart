import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:flutter_application_1/features/auth/data/auth_repository.dart';
import 'package:flutter_application_1/core/models/user_dto.dart';
import 'package:flutter_application_1/routes/routes.dart';

import 'widgets/locket_post_card.dart';
import 'widgets/capture_button.dart';
import 'widgets/home_top_bar.dart';
import 'widgets/home_bottom_nav.dart';
import 'widgets/friends_tab.dart';

class HomeScreen extends StatefulWidget {
  final UserDTO? me;
  const HomeScreen({super.key, this.me});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  int _tab = 0; // 0: Home, 1: Friends

  final _userApi = AuthRepository();
  UserDTO? _me;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkAccount();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkAccount();
    }
  }

  Future<void> _checkAccount() async {
    setState(() => _loading = true);
    try {
      final me = await _userApi.getAccount();
      if (!mounted) return;
      setState(() {
        _me = me;
        _loading = false;
      });
    } on AuthException {
      if (!mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.login, (r) => false);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không lấy được thông tin tài khoản.')),
      );
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.login, (r) => false);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // Nền gradient
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isDark
                      ? const [Color(0xFF0F172A), Color(0xFF1F2937)]
                      : const [Color(0xFFFAFAFF), Color(0xFFEFF3FF)],
                ),
              ),
            ),
          ),
          // hoạ tiết mờ
          Positioned(
            top: -60,
            right: -40,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.purpleAccent.withOpacity(0.25),
              ),
            ),
          ),
          Positioned(
            bottom: -40,
            left: -30,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.lightBlueAccent.withOpacity(0.25),
              ),
            ),
          ),

          // Nội dung chính
          SafeArea(
            child: Column(
              children: [
                // Bạn có thể truyền _me để hiện tên/ảnh nếu HomeTopBar hỗ trợ
                const HomeTopBar(),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _tab == 0
                        ? const _HomeFeed()
                        : const FriendsTab(quota: 20),
                  ),
                ),
              ],
            ),
          ),

          // Nút chụp ảnh giữa đáy
          const Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: EdgeInsets.only(bottom: 22),
              child: CaptureButton(),
            ),
          ),
        ],
      ),

      // Bottom navigation mờ + lồi nút giữa
      bottomNavigationBar: HomeBottomNav(
        currentIndex: _tab,
        onChanged: (i) => setState(() => _tab = i),
      ),
    );
  }
}

class _HomeFeed extends StatelessWidget {
  const _HomeFeed();

  @override
  Widget build(BuildContext context) {
    final items = List.generate(8, (i) => i);
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemBuilder: (_, i) => LocketPostCard(
        username: i.isEven ? 'Minh Anh' : 'Thắng',
        timeText: i == 0 ? 'Vừa xong' : '${10 + i}m',
        // CHÚ Ý: asset nên là 'data/assets/...'
        avatarAsset: 'lib/data/assets/locket_app_icon-01.png',
        imageAsset: 'lib/data/assets/locket_app_icon-01.png',
        liked: i % 3 == 0,
        onLike: () {},
        onComment: () {},
        onSend: () {},
      ),
      separatorBuilder: (_, __) => const SizedBox(height: 14),
      itemCount: items.length,
    );
  }
}
