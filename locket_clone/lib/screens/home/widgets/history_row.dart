import 'package:flutter/material.dart';

class HistoryRow extends StatelessWidget {
  final VoidCallback? onTap;

  const HistoryRow({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(width: 10),
          const Text(
            'Lịch sử',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.expand_more, color: Colors.white70, size: 20),
        ],
      ),
    );
  }
}
