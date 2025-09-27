import 'dart:ui';
import 'package:flutter/material.dart';

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.55),
              border: Border.all(color: Colors.white.withOpacity(0.25)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundImage: AssetImage(
                    'lib/data/assets/locket_app_icon-01.png',
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  'Khoảnh khắc',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton.filledTonal(
                  onPressed: () {},
                  icon: const Icon(Icons.send_outlined),
                  tooltip: 'Gửi nhanh',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
