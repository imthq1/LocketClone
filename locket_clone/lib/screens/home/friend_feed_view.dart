import 'package:flutter/material.dart';
import 'package:locket_clone/theme/app_colors.dart';

class FriendFeedView extends StatelessWidget {
  const FriendFeedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.arrow_upward, color: AppColors.textSecondary, size: 30),
            SizedBox(height: 16),
            Text(
              'Cuộn lên để mở camera',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
            ),
            SizedBox(height: 40),
            Text(
              '(Đây là nơi hiển thị Feed bạn bè)',
              style: TextStyle(color: AppColors.textHint, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}