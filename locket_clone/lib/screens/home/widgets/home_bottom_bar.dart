import 'package:flutter/material.dart';
import 'package:locket_clone/screens/home/widgets/history_row.dart';

class HomeBottomBar extends StatelessWidget {
  final VoidCallback? onHistoryPressed;
  const HomeBottomBar({
    super.key,
    this.onHistoryPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: HistoryRow(
        onTap: onHistoryPressed,
      ),
    );
  }
}
