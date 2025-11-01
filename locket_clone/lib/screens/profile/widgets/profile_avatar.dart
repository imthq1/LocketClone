import 'package:flutter/material.dart';
import 'package:locket_clone/theme/app_colors.dart';

class ProfileAvatar extends StatelessWidget {
  final String initials;
  const ProfileAvatar({super.key, required this.initials});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0x33FFFFFF), width: 8.0),
      ),
      child: CircleAvatar(
        radius: 82,
        backgroundColor: AppColors.fieldBackground,
        child: Text(
          initials,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
