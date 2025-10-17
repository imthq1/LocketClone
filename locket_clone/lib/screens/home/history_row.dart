import 'package:flutter/material.dart';
import 'package:locket_clone/screens/home/history_sheet.dart';
import 'package:locket_clone/services/application/post_controller.dart';
import 'package:provider/provider.dart';
import 'package:locket_clone/shared/cloudinary_helper.dart';

class HistoryRow extends StatelessWidget {
  const HistoryRow({super.key});

  @override
  Widget build(BuildContext context) {
    final feed = context.watch<PostController>();
    final thumbUrl = (feed.items.isNotEmpty)
        ? buildCloudinaryUrl(feed.items.first.image)
        : null;

    return GestureDetector(
      onTap: () async {
        // bảo đảm có dữ liệu (nếu chưa có sẽ load trong sheet)
        if (feed.items.isEmpty && !feed.isLoading) {
          await feed.load(size: 20);
        }
        // mở bottom-sheet giống locket
        // ignore: use_build_context_synchronously
        await showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          barrierColor: Colors.black54,
          builder: (_) => const HistorySheet(),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 32,
              height: 32,
              color: Colors.white24,
              child: thumbUrl != null
                  ? Image.network(thumbUrl, fit: BoxFit.cover)
                  : const Icon(Icons.image, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'History',
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
