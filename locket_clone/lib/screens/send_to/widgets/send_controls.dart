import 'package:flutter/material.dart';
import 'package:locket_clone/theme/app_colors.dart';

class SendControls extends StatelessWidget {
  final VoidCallback? onCancelPressed;
  final VoidCallback? onSendPressed;

  final double cancelIconSize;
  final double sendButtonSize;
  final double sendIconSize;

  const SendControls({
    super.key,
    this.onCancelPressed,
    this.onSendPressed,
    this.cancelIconSize = 36.0,
    this.sendButtonSize = 72.0,
    this.sendIconSize = 32.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nút Hủy (X)
          IconButton(
            onPressed: onCancelPressed,
            icon: const Icon(Icons.close, color: AppColors.textPrimary),
            iconSize: cancelIconSize,
          ),

          // Nút Gửi (Send)
          GestureDetector(
            onTap: onSendPressed,
            child: Container(
              width: sendButtonSize,
              height: sendButtonSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade800,
              ),
              child: Icon(
                Icons.send_rounded,
                color: AppColors.textPrimary,
                size: sendIconSize,
              ),
            ),
          ),
          SizedBox(width: cancelIconSize),
        ],
      ),
    );
  }
}
