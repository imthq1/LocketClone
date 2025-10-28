import 'package:flutter/material.dart';
import 'package:locket_clone/screens/home/widgets/shutter_button.dart';
import 'package:locket_clone/theme/app_colors.dart';

class FeedBottomBar extends StatelessWidget {
  final VoidCallback? onGridPressed;
  final VoidCallback? onShutterPressed;

  const FeedBottomBar({super.key, this.onGridPressed, this.onShutterPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Nút Grid
          IconButton(
            onPressed: onGridPressed,
            icon: const Icon(
              Icons.grid_view_rounded,
              color: AppColors.textPrimary,
            ),
            iconSize: 32,
          ),

          // Nút Chụp
          ShutterButton(onPressed: onShutterPressed, size: 84),

          // Đối trọng để giữ nút Shutter ở giữa
          const SizedBox(width: 32),
        ],
      ),
    );
  }
}
