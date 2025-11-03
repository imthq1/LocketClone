import 'package:flutter/material.dart';
import 'package:locket_clone/services/data/models/chat_dto.dart';
import 'package:locket_clone/shared/cloudinary_helper.dart';

class MessageList extends StatelessWidget {
  final ScrollController controller;
  final List<MessageDTO> messages;
  final int? meId;
  final VoidCallback onBuilt;

  const MessageList({
    super.key,
    required this.controller,
    required this.messages,
    required this.meId,
    required this.onBuilt,
  });

  @override
  Widget build(BuildContext context) {
    final sorted = [...messages]
      ..sort((a, b) {
        final ta = a.createdAt?.millisecondsSinceEpoch ?? 0;
        final tb = b.createdAt?.millisecondsSinceEpoch ?? 0;
        return ta.compareTo(tb);
      });

    WidgetsBinding.instance.addPostFrameCallback((_) => onBuilt());

    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      itemCount: sorted.length,
      itemBuilder: (_, i) {
        final m = sorted[i];
        final sender = m.senderId ?? m.sender?.id;
        final isMe = (meId != null) && (sender == meId);

        return Bubble(message: m, isMe: isMe);
      },
    );
  }
}

class Bubble extends StatelessWidget {
  final MessageDTO message;
  final bool isMe;
  const Bubble({super.key, required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final text = (message.content ?? '').trim();
    final time = fmtTime(message.createdAt);
    final imageUrl = message.image?.trim();
    final hasImage = imageUrl != null && imageUrl.isNotEmpty;

    final bg = isMe ? const Color(0xFF2F6FED) : const Color(0xFF1E1E1E);
    final fg = Colors.white;
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final radius = BorderRadius.only(
      topLeft: const Radius.circular(16),
      topRight: const Radius.circular(16),
      bottomLeft: Radius.circular(isMe ? 16 : 4),
      bottomRight: Radius.circular(isMe ? 4 : 16),
    );

    return Padding(
      padding: EdgeInsets.fromLTRB(isMe ? 60 : 8, 4, isMe ? 8 : 60, 4),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Container(
            decoration: BoxDecoration(color: bg, borderRadius: radius),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Column(
              crossAxisAlignment: align,
              children: [
                if (hasImage) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      buildCloudinaryUrl(imageUrl),
                      width: 220,
                      height: 160,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 220,
                        height: 160,
                        color: Colors.black26,
                        alignment: Alignment.center,
                        child: const Text(
                          'Không tải được ảnh',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                      loadingBuilder: (ctx, child, progress) {
                        if (progress == null) return child;
                        return SizedBox(
                          width: 220,
                          height: 160,
                          child: Center(
                            child: CircularProgressIndicator(
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded /
                                        progress.expectedTotalBytes!
                                  : null,
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (text.isNotEmpty) const SizedBox(height: 6),
                ],
                if (text.isNotEmpty)
                  Text(text, style: TextStyle(color: fg, fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                time,
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
              if (isMe && (message.read == true)) ...[
                const SizedBox(width: 4),
                const Icon(Icons.check_circle, color: Colors.white38, size: 12),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class Loading extends StatelessWidget {
  const Loading({super.key});
  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }
}

String fmtTime(DateTime? dt) {
  if (dt == null) return '';
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

String initialOf(String s) {
  final t = s.trim();
  if (t.isEmpty) return 'U';
  return String.fromCharCodes(t.runes.take(1));
}
