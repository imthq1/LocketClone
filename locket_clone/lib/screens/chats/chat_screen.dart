import 'package:flutter/material.dart';
import 'package:locket_clone/screens/friends/utils/initials.dart';
import 'package:locket_clone/shared/cloudinary_helper.dart';
import 'package:locket_clone/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:locket_clone/services/application/auth_controller.dart';
import 'package:locket_clone/services/application/chat_controller.dart';
import 'package:locket_clone/services/data/models/chat_dto.dart';
import 'package:locket_clone/services/repository/chat_repository.dart';
import 'package:locket_clone/services/websocket/websocket_service.dart';
import 'widgets/chat_widgets.dart';

class ChatScreen extends StatelessWidget {
  final String emailRq;
  final ChatUserDTO? partnerPrefill;

  const ChatScreen({super.key, required this.emailRq, this.partnerPrefill});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) =>
          ChatController(ctx.read<ChatRepository>(), WebSocketService.I)
            ..loadConversationByEmail(emailRq),
      child: _ChatScreenView(partnerPrefill: partnerPrefill),
    );
  }
}

class _ChatScreenView extends StatefulWidget {
  final ChatUserDTO? partnerPrefill;
  const _ChatScreenView({this.partnerPrefill});

  @override
  State<_ChatScreenView> createState() => _ChatScreenViewState();
}

class _ChatScreenViewState extends State<_ChatScreenView> {
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (!_scrollCtrl.hasClients) return;
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;

    final chat = context.read<ChatController>();
    final auth = context.read<AuthController>();
    final meId = auth.user?.id;
    if (meId == null) return;

    chat.sendMessage(senderId: meId, content: text);

    _textCtrl.clear();
    _scrollToBottom();
  }

  void _onChangedText(String v) {
    context.read<ChatController>().notifyTyping(v.isNotEmpty);
  }

  void _sendReadIfNeeded() {
    final chat = context.read<ChatController>();
    final meId = context.read<AuthController>().user?.id;
    final messages = chat.conversation?.messages ?? const <MessageDTO>[];
    if (meId == null || messages.isEmpty) return;

    final last = messages.last;
    final sender = last.senderId ?? last.sender?.id;
    if (sender != null && sender != meId && last.read != true) {
      chat.sendReadEvent(last.id);
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 18,
              backgroundColor: const Color(0xFF222222),
              backgroundImage: (partner?.imageUrl?.isNotEmpty ?? false)
                  ? NetworkImage(buildCloudinaryUrl(partner!.imageUrl!))
                  : null,
              child: (partner?.imageUrl?.isNotEmpty ?? false)
                  ? null
                  : Text(
                      initialsFrom(partner?.fullname ?? "User"),
                      style: const TextStyle(color: AppColors.textPrimary),
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
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (chat.partnerTyping) ...[
                    const SizedBox(height: 2),
                    const Text(
                      'Đang nhập…',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Consumer<WebSocketService>(
              builder: (context, ws, child) {
                return Icon(
                  ws.isConnected ? Icons.wifi : Icons.wifi_off,
                  size: 16,
                  color: ws.isConnected ? Colors.greenAccent : Colors.white30,
                );
              },
            ),
            const SizedBox(width: 16),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: (isLoading && conv == null)
                ? const Loading()
                : MessageList(
                    controller: _scrollCtrl,
                    messages: conv?.messages ?? const [],
                    meId: meId,
                    onBuilt: () {
                      _scrollToBottom();
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
                      style: const TextStyle(color: AppColors.textPrimary),
                      minLines: 1,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Nhắn tin…',
                        hintStyle: const TextStyle(
                          color: AppColors.textSecondary,
                        ),
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
                    icon: const Icon(
                      Icons.send_rounded,
                      color: AppColors.textPrimary,
                    ),
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
