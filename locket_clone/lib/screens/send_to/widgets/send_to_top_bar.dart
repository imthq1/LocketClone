import 'package:flutter/material.dart';
import 'package:locket_clone/theme/app_colors.dart';

class SendToTopBar extends StatelessWidget {
  final VoidCallback? onDownloadPressed;
  final bool isDownloading;
  final bool isDownloadSuccess;

  const SendToTopBar({
    super.key,
    this.onDownloadPressed,
    this.isDownloading = false,
    this.isDownloadSuccess = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = isDownloading || isDownloadSuccess;
    final IconData iconData;

    if (isDownloadSuccess) {
      iconData = Icons.check_circle_outline;
    } else if (isDownloading) {
      iconData = Icons.file_download_off_outlined;
    } else {
      iconData = Icons.file_download_outlined;
    }

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
            onPressed: isDisabled ? null : onDownloadPressed,
            icon: Icon(iconData, color: AppColors.textPrimary, size: 28),
          ),
        ],
      ),
    );
  }
}
