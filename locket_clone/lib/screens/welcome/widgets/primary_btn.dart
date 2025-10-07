import 'package:flutter/material.dart';
import 'package:locket_clone/theme/app_colors.dart';

class PrimaryBtn extends StatelessWidget {
  const PrimaryBtn({super.key, required this.label, required this.onPressed});
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandYellow,
          foregroundColor: AppColors.background,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          shape: const StadiumBorder(),
          elevation: 0,
        ),
        child: Text(label),
      ),
    );
  }
}
