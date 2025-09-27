import 'package:flutter/material.dart';

class CaptureButton extends StatelessWidget {
  const CaptureButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 78,
      height: 78,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 78,
            height: 78,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF06B6D4)],
              ),
            ),
          ),
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.95),
            ),
            child: const Icon(Icons.camera_alt_rounded, size: 28),
          ),
        ],
      ),
    );
  }
}
