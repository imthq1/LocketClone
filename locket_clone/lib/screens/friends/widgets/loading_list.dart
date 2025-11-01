import 'package:flutter/material.dart';
import 'package:locket_clone/theme/app_colors.dart';

class LoadingList extends StatelessWidget {
  const LoadingList();
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        4,
        (i) => const ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.textSecondary,
            radius: 26,
          ),
          title: SizedBox(
            height: 12,
            child: DecoratedBox(
              decoration: BoxDecoration(color: AppColors.textSecondary),
            ),
          ),
          subtitle: SizedBox(
            height: 10,
            child: DecoratedBox(
              decoration: BoxDecoration(color: AppColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}
