import 'package:flutter/material.dart';
import 'package:locket_clone/services/application/friends_controller.dart';
import 'package:provider/provider.dart';

class SearchResult extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<FriendsController>();

    if (ctrl.query.isEmpty) return const SizedBox.shrink();
    if (ctrl.isSearching) {
      return const ListTile(
        leading: SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        title: Text('Đang tìm...'),
      );
    }
    if (ctrl.notFound) {
      return const ListTile(
        leading: Icon(Icons.search_off),
        title: Text('Không tìm thấy người dùng'),
        subtitle: Text('Hãy kiểm tra lại email.'),
      );
    }
    if (ctrl.searchResult != null) {
      final user = ctrl.searchResult!;
      final hasImg = (user.image != null && user.image!.isNotEmpty);
      return ListTile(
        leading: CircleAvatar(
          backgroundImage: hasImg ? NetworkImage(user.image!) : null,
          child: !hasImg ? const Icon(Icons.person) : null,
        ),
        title: Text(user.fullname),
        subtitle: Text(user.email),
        trailing: FilledButton(
          onPressed: ctrl.isSendingRequest || ctrl.searchResult == null
              ? null
              : () async {
                  final ok = await ctrl.sendFriendRequestFromSearch();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          ok
                              ? 'Đã gửi lời mời kết bạn'
                              : (ctrl.error ?? 'Gửi lời mời thất bại'),
                        ),
                      ),
                    );
                  }
                },
          child: ctrl.isSendingRequest
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Kết bạn'),
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
