import 'package:flutter/material.dart';
import 'package:locket_clone/services/application/friends_controller.dart';
import 'package:provider/provider.dart';
import 'package:locket_clone/screens/friends/widgets/status_chip.dart';

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
      final rel = ctrl.searchRelation ?? RelationStatus.none;

      Widget trailing;
      switch (rel) {
        case RelationStatus.self:
          trailing = const StatusChip('Đây là bạn');
          break;
        case RelationStatus.friend:
          trailing = const StatusChip('Đã là bạn');
          break;
        case RelationStatus.outgoing:
          trailing = const StatusChip('Đã gửi lời mời');
          break;
        case RelationStatus.incoming:
          trailing = const StatusChip('Chờ bạn xác nhận');
          break;
        case RelationStatus.none:
          trailing = FilledButton(
            onPressed: ctrl.isSendingRequest
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
          );
          break;
      }

      return ListTile(
        leading: CircleAvatar(
          backgroundImage: hasImg ? NetworkImage(user.image!) : null,
          child: !hasImg ? const Icon(Icons.person) : null,
        ),
        title: Text(user.fullname),
        subtitle: Text(user.email),
        trailing: trailing,
      );
    }

    return const SizedBox.shrink();
  }
}
