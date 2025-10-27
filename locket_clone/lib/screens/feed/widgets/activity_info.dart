import 'package:flutter/material.dart';
import 'package:locket_clone/theme/app_colors.dart';

class ActivityInfo extends StatelessWidget {
  const ActivityInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        // Yêu cầu 2: Cập nhật màu
        color:
            AppColors.fieldBackground, // Thay vì Colors.white.withOpacity(0.1)
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.star_border, color: AppColors.brandYellow, size: 18),
          SizedBox(width: 8),
          Text(
            'Chưa có hoạt động nào!',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
