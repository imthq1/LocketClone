import 'package:flutter/material.dart';
import 'package:locket_clone/theme/app_colors.dart';

class ShutterButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final double size;

  const ShutterButton({super.key, this.onPressed, this.size = 72});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.brandYellow, width: 4),
        ),
        padding: const EdgeInsets.all(4),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
