import 'package:flutter/material.dart';
import 'package:locket_clone/services/auth/application/friends_controller.dart';
import 'package:provider/provider.dart';
import 'package:locket_clone/services/auth/data/models/user_dto.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<FriendsController>();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Messages',
          style: TextStyle(color: Color.fromARGB(255, 156, 129, 129), fontWeight: FontWeight.w600),
        ),
      ),
      body: RefreshIndicator(
        color: Colors.white,
        backgroundColor: Colors.black,
        onRefresh: ctrl.refresh,
        child: Builder(
          builder: (_) {
            if (ctrl.isLoading && ctrl.friends.isEmpty) {
              return const _LoadingList();
            }
            if (ctrl.error != null && ctrl.friends.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  Center(
                    child: Text(
                      ctrl.error!,
                      style: const TextStyle(color: Colors.white60),
                    ),
                  ),
                ],
              );
            }
            final items = ctrl.friends;
            if (items.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(
                    child: Text(
                      'Chưa có bạn nào trong danh sách.',
                      style: TextStyle(color: Colors.white60),
                    ),
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              separatorBuilder: (_, __) => const Divider(
                height: 1,
                color: Color(0x22FFFFFF),
                indent: 72,
              ),
              itemBuilder: (_, i) => _ChatRow(user: items[i]),
            );
          },
        ),
      ),
    );
  }
}

class _ChatRow extends StatelessWidget {
  final UserDTO user;
  const _ChatRow({required this.user});

  String _initialOf(String s) {
    final t = (s).trim();
    if (t.isEmpty) return 'U';
    return String.fromCharCodes(t.runes.take(1));
  }

  @override
  Widget build(BuildContext context) {
    final name = (user.fullname.isNotEmpty) ? user.fullname : user.email;
    final avatarUrl = (user.image ?? '').trim();

    return ListTile(
      onTap: () {
        // TODO: mở màn hình chat với user.id
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(color: Colors.black87, blurRadius: 6, spreadRadius: 1),
          ],
          border: Border.all(color: const Color(0x33FFFFFF), width: 1),
        ),
        child: CircleAvatar(
          backgroundColor: const Color(0xFF222222),
          backgroundImage: avatarUrl.isNotEmpty
              ? NetworkImage(avatarUrl)
              : null,
          child: avatarUrl.isEmpty
              ? Text(
                  _initialOf(name),
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                )
              : null,
        ),
      ),
      title: Text(
        name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: const Text(
        'Say hi 👋', // chưa có lastMessage từ API
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.white60, fontSize: 14),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          // Placeholder ngày giờ (chưa có field time từ API)
          // Text('4 Jun', style: TextStyle(color: Colors.white38, fontSize: 12)),
          Icon(Icons.chevron_right, color: Colors.white38),
        ],
      ),
    );
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: 8,
      separatorBuilder: (_, __) =>
          const Divider(height: 1, color: Color(0x22FFFFFF), indent: 72),
      itemBuilder: (_, __) => const ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        leading: CircleAvatar(radius: 27, backgroundColor: Color(0x22FFFFFF)),
        title: _ShimmerBar(width: 140),
        subtitle: Padding(
          padding: EdgeInsets.only(top: 6),
          child: _ShimmerBar(width: 90),
        ),
      ),
    );
  }
}

class _ShimmerBar extends StatelessWidget {
  final double width;
  const _ShimmerBar({required this.width});
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 12,
      width: width,
      decoration: BoxDecoration(
        color: const Color(0x22FFFFFF),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}
