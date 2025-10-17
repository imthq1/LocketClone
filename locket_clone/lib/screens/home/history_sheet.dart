import 'package:flutter/material.dart';
import 'package:locket_clone/services/application/post_controller.dart';
import 'package:locket_clone/services/data/models/post_dto.dart';
import 'package:provider/provider.dart';
import 'package:locket_clone/shared/cloudinary_helper.dart';

class HistorySheet extends StatefulWidget {
  const HistorySheet({super.key});

  @override
  State<HistorySheet> createState() => _HistorySheetState();
}

class _HistorySheetState extends State<HistorySheet> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    final ctrl = context.read<PostController>();
    if (ctrl.items.isEmpty && !ctrl.isLoading) {
      ctrl.load(size: 20);
    }
    _scroll.addListener(() {
      final c = context.read<PostController>();
      if (_scroll.position.pixels > _scroll.position.maxScrollExtent - 280) {
        c.loadMore();
      }
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<PostController>();
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.72,
            child: Builder(
              builder: (_) {
                if (ctrl.isLoading && ctrl.items.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }
                if (ctrl.error != null && ctrl.items.isEmpty) {
                  return Center(
                    child: Text(
                      ctrl.error!,
                      style: const TextStyle(color: Colors.white60),
                    ),
                  );
                }
                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.only(bottom: 12),
                  itemCount: ctrl.items.length + (ctrl.isLoadingMore ? 1 : 0),
                  itemBuilder: (context, i) {
                    if (i >= ctrl.items.length) {
                      return const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      );
                    }
                    final p = ctrl.items[i];
                    return _HistoryCard(post: p);
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final PostDTO post;
  const _HistoryCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final imgUrl = buildCloudinaryUrl(post.image);
    final author = post.authorFullname ?? post.authorEmail ?? 'Unknown';
    final when = _shortAgo(post.createdAt);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            AspectRatio(
              aspectRatio: 3 / 4, // giống thẻ ảnh locket
              child: imgUrl.isNotEmpty
                  ? Image.network(imgUrl, fit: BoxFit.cover)
                  : Container(color: const Color(0x22FFFFFF)),
            ),
            // caption bubble
            if ((post.caption).trim().isNotEmpty)
              Positioned(
                left: 12,
                right: 12,
                bottom: 44,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xAA3A3A3A),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    post.caption,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            // author + time
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.white24,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(when, style: const TextStyle(color: Colors.white70)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String _shortAgo(DateTime? t) {
  if (t == null) return '';
  final now = DateTime.now();
  final diff = now.difference(t);
  if (diff.inMinutes < 1) return 'now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';
  final d = t;
  return '${d.day}/${d.month}';
}
