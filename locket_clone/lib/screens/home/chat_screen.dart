import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:locket_clone/core/storage/secure_storage.dart';
import 'package:locket_clone/shared/cloudinary_helper.dart';
import 'package:provider/provider.dart';

import 'package:locket_clone/services/application/auth_controller.dart';
import 'package:locket_clone/services/application/chat_controller.dart';
import 'package:locket_clone/services/data/models/chat_dto.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';

class ChatScreen extends StatefulWidget {
  final String emailRq;
  final ChatUserDTO? partnerPrefill;
  ChatScreen({super.key, required this.emailRq, this.partnerPrefill});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final SecureStorage _storage = SecureStorage();
  // ===== WebSocket state =====
  StompClient? _stomp;
  bool _wsConnected = false;
  StreamSubscription? _autoSub; // auto-subscribe khi convId sẵn sàng

  // Subscriptions
  void Function()? _unsubConv; // /topic/conversations.{id}
  void Function()? _unsubTyping; // /user/queue/typing

  // Typing debounce
  Timer? _typingDebounce;
  bool _partnerTyping = false;

  @override
  void initState() {
    super.initState();

    // 1) Load conversation qua REST
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final chat = context.read<ChatController>();
      await chat.loadConversationByEmail(widget.emailRq);

      // 2) Kết nối WebSocket sau khi có token
      final token = await _storage.readAccessToken();
      if (token != null && token.isNotEmpty) {
        _connectWs(token);
      }

      // 3) Khi conversation sẵn sàng → subscribe topic
      _autoSub = chat.conversationStream.listen((convId) {
        if (_wsConnected && convId != null) {
          _subscribeConversation(convId);
        }
      });
    });
  }

  @override
  void dispose() {
    _typingDebounce?.cancel();
    _unsubConv?.call();
    _unsubTyping?.call();
    _autoSub?.cancel();
    _stomp?.deactivate();
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ===== WebSocket connect & subscribe =====
  void _connectWs(String jwt) {
    if (_stomp?.connected == true) return;

    _stomp = StompClient(
      config: StompConfig(
        url: _wsUrl(),
        onConnect: (frame) {
          setState(() => _wsConnected = true);
          final convId = context.read<ChatController>().conversation?.id;
          if (convId != null) _subscribeConversation(convId);
        },
        onWebSocketError: (err) {
          setState(() => _wsConnected = false);
        },
        onDisconnect: (_) => setState(() => _wsConnected = false),
        stompConnectHeaders: {'Authorization': 'Bearer $jwt'},
        webSocketConnectHeaders: {'Authorization': 'Bearer $jwt'},
        heartbeatIncoming: const Duration(seconds: 0),
        heartbeatOutgoing: const Duration(seconds: 0),
      ),
    );

    _stomp!.activate();
  }

  String _wsUrl() {
    return 'ws://10.0.2.2:8080/ws/websocket';
  }

  void _subscribeConversation(int conversationId) {
    // Hủy sub cũ
    _unsubConv?.call();
    _unsubTyping?.call();

    // Nhận message + read-event từ topic chung
    final subConv = _stomp?.subscribe(
      destination: '/topic/conversations.$conversationId',
      callback: (StompFrame f) {
        if (f.body == null) return;
        final map = jsonDecode(f.body!);

        final msg = MessageDTO.fromJson(map);
        context.read<ChatController>().appendIncomingMessage(msg);
        _scrollToBottom();
      },
    );

    // subcriber /user/queue/typing
    final subTyping = _stomp?.subscribe(
      destination: '/user/queue/typing',
      callback: (f) {
        if (f.body == null) return;
        print('typing payload: ${f.body}'); // ← phải thấy
        final e = jsonDecode(f.body!) as Map<String, dynamic>;
        final cid = (e['conversationId'] as num?)?.toInt();
        if (cid == conversationId) {
          final typing = e['typing'] == true;
          setState(() => _partnerTyping = typing);
          if (typing) {
            Future.delayed(const Duration(seconds: 5), () {
              if (mounted) setState(() => _partnerTyping = false);
            });
          }
        }
      },
    );

    _unsubConv = subConv;
    _unsubTyping = subTyping;
  }

  // ===== UI helpers =====
  void _scrollToBottom() {
    if (!_scrollCtrl.hasClients) return;
    _scrollCtrl.animateTo(
      _scrollCtrl.position.maxScrollExtent + 80,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _send() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;

    final chat = context.read<ChatController>();
    final auth = context.read<AuthController>();
    final meId = auth.user?.id;
    final convId = chat.conversation?.id;
    if (meId == null || convId == null) return;

    // Ưu tiên WS; nếu chưa thì fallback REST
    if (_wsConnected && _stomp?.connected == true) {
      _stomp?.send(
        destination: '/app/conversations/$convId/send',
        body: jsonEncode({'senderId': meId, 'content': text, 'image': null}),
      );
    } else {
      await chat.sendMessage(senderId: meId, content: text);
    }

    _textCtrl.clear();
    _scrollToBottom();
    _notifyTyping(false);
  }

  void _notifyTyping(bool typing) {
    final chat = context.read<ChatController>();
    final user = context.read<AuthController>();
    final currentUser = user.loginDTO;
    final convId = chat.conversation?.id;
    if (!_wsConnected || convId == null) return;

    _stomp?.send(
      destination: '/app/conversations/$convId/typing',
      headers: {'content-type': 'application/json'},
      body: jsonEncode({
        'typing': typing,
        'currentUserId': currentUser?.userLogin.id,
      }),
    );
  }

  void _onChangedText(String v) {
    if (!_wsConnected) return;
    _notifyTyping(true);
    _typingDebounce?.cancel();
    _typingDebounce = Timer(
      const Duration(seconds: 2),
      () => _notifyTyping(false),
    );
  }

  void _sendReadIfNeeded() {
    final chat = context.read<ChatController>();
    final meId = context.read<AuthController>().user?.id;
    final convId = chat.conversation?.id;
    final messages = chat.conversation?.messages ?? const <MessageDTO>[];
    if (!_wsConnected || convId == null || meId == null || messages.isEmpty)
      return;

    final last = messages.last;
    if (last.sender?.id != meId && (last.read != true)) {
      _stomp?.send(
        destination: '/app/conversations/$convId/read',
        body: jsonEncode({'messageId': last.id}),
      );
    }
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
        return (conv.user1.id == meId) ? conv.user2 : conv.user1;
      }
      return widget.partnerPrefill;
    })();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sendReadIfNeeded());

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
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
                  if (_partnerTyping) ...[
                    const SizedBox(height: 2),
                    const Text(
                      'Đang nhập…',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              _wsConnected ? Icons.wifi : Icons.wifi_off,
              size: 16,
              color: _wsConnected ? Colors.greenAccent : Colors.white30,
            ),
            const SizedBox(width: 8),
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
                    onBuilt: () {
                      _scrollToBottom();
                      _sendReadIfNeeded();
                    },
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
                      onChanged: _onChangedText,
                      onSubmitted: (_) => _send(),
                      textInputAction: TextInputAction.send,
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
        final isMe =
            (meId != null) && ((m.sender?.id == meId) || (m.senderId == meId));

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
                      buildCloudinaryUrl(imageUrl!),
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
