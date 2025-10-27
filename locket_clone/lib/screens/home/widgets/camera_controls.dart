import 'package:flutter/material.dart';
import 'package:locket_clone/screens/home/widgets/shutter_button.dart';
import 'package:locket_clone/theme/app_colors.dart';

class CameraControls extends StatelessWidget {
  final VoidCallback? onFlashPressed;
  final VoidCallback? onShutterPressed;
  final VoidCallback? onFlipPressed;
  final bool isFlashOn;

  const CameraControls({
    super.key,
    this.onFlashPressed,
    this.onShutterPressed,
    this.onFlipPressed,
    this.isFlashOn = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: onFlashPressed,
            icon: Icon(
              isFlashOn ? Icons.bolt : Icons.flash_on,
              color: isFlashOn ? AppColors.brandYellow : AppColors.textPrimary,
            ),
            iconSize: 32,
          ),

          // Nút Chụp
          ShutterButton(onPressed: onShutterPressed, size: 84),

          // Nút Lật camera
          IconButton(
            onPressed: onFlipPressed,
            icon: const Icon(
              Icons.flip_camera_ios_outlined,
              color: AppColors.textPrimary,
            ),
            iconSize: 32,
          ),
        ],
      ),
    );
  }
}
