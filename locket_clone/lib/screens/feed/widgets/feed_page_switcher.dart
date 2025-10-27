import 'package:flutter/material.dart';
import 'package:locket_clone/theme/app_colors.dart';

class FeedPageSwitcher extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onPageChanged;

  const FeedPageSwitcher({
    super.key,
    required this.currentIndex,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // Đặt widget này ngay dưới HomeTopBar
      padding: const EdgeInsets.only(top: 80, bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _SwitcherButton(
            label: 'Của tôi',
            isActive: currentIndex == 0,
            onPressed: () => onPageChanged(0),
          ),
          const SizedBox(width: 16),
          _SwitcherButton(
            label: 'Bạn bè',
            isActive: currentIndex == 1,
            onPressed: () => onPageChanged(1),
          ),
        ],
      ),
    );
  }
}

class _SwitcherButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  const _SwitcherButton({
    required this.label,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
        ),
      ),
    );
  }
}
