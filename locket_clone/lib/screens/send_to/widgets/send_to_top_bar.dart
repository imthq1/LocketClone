import 'package:flutter/material.dart';
import 'package:locket_clone/theme/app_colors.dart';

class SendToTopBar extends StatelessWidget {
  final VoidCallback? onDownloadPressed;

  const SendToTopBar({super.key, this.onDownloadPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 48),
          const Text(
            'Gửi đến...',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          IconButton(
            onPressed: onDownloadPressed,
            icon: const Icon(
              Icons.download_outlined,
              color: AppColors.textPrimary,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }
}
