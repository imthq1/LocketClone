import 'dart:ui';
import 'package:flutter/material.dart';

import 'package:flutter_application_1/core/models/friend_models.dart';
import 'package:flutter_application_1/features/auth/data/friend_repository.dart';
import 'friends_shared_widgets.dart';

class FriendsTab extends StatefulWidget {
  final int quota;
  const FriendsTab({super.key, this.quota = 20});

  @override
  State<FriendsTab> createState() => _FriendsTabState();
}

class _FriendsTabState extends State<FriendsTab> {
  final _repo = FriendRepository();

  bool _loading = true;
  String? _error;

  List<FriendRequestReceived> _received = [];
  final _sent = <FriendRequestSent>[];
  PageMeta? _sentMeta;
  int _page = 0;
  final int _size = 20;
  bool _loadingMore = false;

  @override
  void initState() {
    super.initState();
    _fetchAll();
  }

  Future<void> _fetchAll() async {
    setState(() {
      _loading = true;
      _error = null;
      _sent.clear();
      _page = 0;
      _sentMeta = null;
    });
    try {
      final r1 = await _repo.listReceived();
      final r2 = await _repo.listSent(page: 0, size: _size);
      setState(() {
        _received = r1;
        _sent.addAll(r2.content);
        _sentMeta = r2.page;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _loadMore() async {
    if (_loadingMore) return;
    if (_sentMeta == null) return;
    if (_page + 1 >= _sentMeta!.totalPages) return;

    setState(() => _loadingMore = true);
    try {
      final next = _page + 1;
      final r = await _repo.listSent(page: next, size: _size);
      setState(() {
        _page = next;
        _sentMeta = r.page;
        _sent.addAll(r.content);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Không tải thêm được: $e')));
      }
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Lỗi: $_error', textAlign: TextAlign.center),
            const SizedBox(height: 8),
            FilledButton(onPressed: _fetchAll, child: const Text('Thử lại')),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchAll,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Counter + Add friend
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    '${_received.length} requests • ${_sent.length} sent',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Invite a friend to continue',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.65,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SearchStub(
                    hint: 'Add a new friend',
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Coming soon ✨')),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Received
            Row(
              children: [
                const Icon(Icons.inbox_outlined, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Requests to you',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (_received.isEmpty)
              GlassCard(
                child: Text(
                  'Không có lời mời mới',
                  style: theme.textTheme.bodyMedium,
                ),
              )
            else
              GlassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: _received
                      .map((r) => _ReceivedTile(item: r))
                      .toList(),
                ),
              ),

            const SizedBox(height: 18),

            // Sent (paging)
            Row(
              children: [
                const Icon(Icons.outbox_outlined, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Requests you sent',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            if (_sent.isEmpty)
              GlassCard(
                child: Text(
                  'Chưa gửi lời mời nào',
                  style: theme.textTheme.bodyMedium,
                ),
              )
            else
              GlassCard(
                padding: EdgeInsets.zero,
                child: Column(
                  children: [
                    for (final s in _sent) _SentTile(item: s),
                    if (_sentMeta != null &&
                        (_page + 1) < _sentMeta!.totalPages)
                      TextButton.icon(
                        onPressed: _loadingMore ? null : _loadMore,
                        icon: _loadingMore
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.expand_more),
                        label: Text(_loadingMore ? 'Đang tải…' : 'Tải thêm'),
                      ),
                  ],
                ),
              ),

            const SizedBox(height: 18),

            // Share
            Text(
              'Share your Locket link',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 10),
            GlassCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: const [
                  ShareTile(label: 'Messenger', icon: Icons.messenger_outline),
                  Divider(height: 1),
                  ShareTile(
                    label: 'Instagram',
                    icon: Icons.camera_alt_outlined,
                  ),
                  Divider(height: 1),
                  ShareTile(label: 'Messages', icon: Icons.sms_outlined),
                  Divider(height: 1),
                  ShareTile(label: 'Copy link', icon: Icons.link_outlined),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final String? url;
  const _Avatar(this.url);

  @override
  Widget build(BuildContext context) {
    final img = (url == null || url!.isEmpty)
        ? const AssetImage('data/assets/locket_app_icon-01.png')
        : NetworkImage(url!);
    return CircleAvatar(radius: 22, backgroundImage: img as ImageProvider);
  }
}

class _ReceivedTile extends StatelessWidget {
  final FriendRequestReceived item;
  const _ReceivedTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _Avatar(item.requesterAvatar),
      title: Text(
        item.requesterFullname,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: (item.createdAt != null)
          ? Text('Requested ${item.createdAt}')
          : null,
      trailing: Wrap(
        spacing: 8,
        children: [
          OutlinedButton(
            onPressed: () {
              // TODO: call API accept
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Accept (TODO)')));
            },
            child: const Text('Accept'),
          ),
          FilledButton(
            onPressed: () {
              // TODO: call API decline
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Decline (TODO)')));
            },
            child: const Text('Decline'),
          ),
        ],
      ),
    );
  }
}

class _SentTile extends StatelessWidget {
  final FriendRequestSent item;
  const _SentTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: _Avatar(item.targetAvatar),
      title: Text(
        item.targetFullname,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(item.status.toUpperCase()),
      trailing: TextButton(
        onPressed: () {
          // TODO: call API cancel
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Cancel (TODO)')));
        },
        child: const Text('Cancel'),
      ),
    );
  }
}
