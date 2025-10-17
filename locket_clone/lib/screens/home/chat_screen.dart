import 'package:flutter/material.dart';
import 'package:locket_clone/services/application/auth_controller.dart';
import 'package:locket_clone/services/application/chat_controller.dart';

import 'package:locket_clone/services/data/models/chat_dto.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final String emailRq; // mở theo email đối phương
  final ChatUserDTO? partnerPrefill; // optional: để hiển thị nhanh header

  const ChatScreen({super.key, required this.emailRq, this.partnerPrefill});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load history
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatController>().loadConversationByEmail(widget.emailRq);
    });
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollCtrl.hasClients) return;
    _scrollCtrl.animateTo(
      _scrollCtrl.position.maxScrollExtent + 80,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatController>();
    final auth = context.watch<AuthController>();
    final meId = auth.user?.id;

    final conv = chat.conversation;
    final isLoading = chat.isLoading;

    final partner = (() {
      if (conv != null && meId != null) {
        // xác định đối tác: user1/user2 khác me
        return (conv.user1.id == meId) ? conv.user2 : conv.user1;
      }
      return widget.partnerPrefill; // fallback (chưa load xong)
    })();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF222222),
              backgroundImage: (partner?.imageUrl?.isNotEmpty ?? false)
                  ? NetworkImage(partner!.imageUrl!)
                  : null,
              child: (partner?.imageUrl?.isNotEmpty ?? false)
                  ? null
                  : Text(
                      _initialOf(partner?.fullname ?? partner?.email ?? 'U'),
                      style: const TextStyle(color: Colors.white),
                    ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                (partner?.fullname.isNotEmpty ?? false)
                    ? partner!.fullname
                    : (partner?.email ?? ''),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading && conv == null
                ? const _Loading()
                : _MessageList(
                    controller: _scrollCtrl,
                    messages: conv?.messages ?? const [],
                    meId: meId,
                    onBuilt: _scrollToBottom,
                  ),
          ),
          const Divider(height: 1, color: Color(0x22FFFFFF)),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textCtrl,
                      style: const TextStyle(color: Colors.white),
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Nhắn tin…',
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: const Color(0xFF161616),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: Color(0x33FFFFFF),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: Color(0x33FFFFFF),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: const BorderSide(
                            color: Color(0x66FFFFFF),
                          ),
                        ),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: _send,
                    icon: const Icon(Icons.send_rounded, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _send() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;

    final chat = context.read<ChatController>();
    final auth = context.read<AuthController>();
    final meId = auth.user?.id;
    if (meId == null) return;

    await chat.sendMessage(senderId: meId, content: text);
    _textCtrl.clear();
    _scrollToBottom();
  }
}

String _initialOf(String s) {
  final t = s.trim();
  if (t.isEmpty) return 'U';
  return String.fromCharCodes(t.runes.take(1));
}

class _MessageList extends StatelessWidget {
  final ScrollController controller;
  final List<MessageDTO> messages;
  final int? meId;
  final VoidCallback onBuilt;

  const _MessageList({
    required this.controller,
    required this.messages,
    required this.meId,
    required this.onBuilt,
  });

  @override
  Widget build(BuildContext context) {
    // sắp xếp tăng dần theo createdAt
    final sorted = [...messages]
      ..sort((a, b) {
        final ta = a.createdAt?.millisecondsSinceEpoch ?? 0;
        final tb = b.createdAt?.millisecondsSinceEpoch ?? 0;
        return ta.compareTo(tb);
      });

    // Dùng ListView + controller để tự cuộn xuống cuối
    WidgetsBinding.instance.addPostFrameCallback((_) => onBuilt());

    return ListView.builder(
      controller: controller,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      itemCount: sorted.length,
      itemBuilder: (_, i) {
        final m = sorted[i];
        final isMe = (meId != null && m.sender?.id == meId);
        return _Bubble(message: m, isMe: isMe);
      },
    );
  }
}

class _Bubble extends StatelessWidget {
  final MessageDTO message;
  final bool isMe;
  const _Bubble({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final text = (message.content ?? '').trim();
    final time = _fmtTime(message.createdAt);
    final hasImage = (message.image?.isNotEmpty ?? false);

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
                  // TODO: build URL từ public_id nếu BE/Cloud hỗ trợ
                  // Hiện để placeholder vì 'image' là "abc"
                  Container(
                    height: 160,
                    width: 220,
                    alignment: Alignment.center,
                    color: Colors.black12,
                    child: const Text(
                      'Ảnh',
                      style: TextStyle(color: Colors.white70),
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
          Text(
            time,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();
  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator(color: Colors.white));
  }
}

String _fmtTime(DateTime? dt) {
  if (dt == null) return '';
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}
