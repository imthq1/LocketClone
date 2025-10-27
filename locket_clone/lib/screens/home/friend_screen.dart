import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:locket_clone/services/auth/application/auth_controller.dart';
import 'package:locket_clone/services/auth/application/friends_controller.dart';
import 'package:locket_clone/services/auth/data/models/user_dto.dart';
import 'package:locket_clone/services/auth/data/models/friend_request_dto.dart';
import 'package:locket_clone/theme/app_colors.dart';
import 'package:locket_clone/services/auth/data/models/friend_request_sent_dto.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final c = context.read<FriendsController>();
      c.load(); // bạn bè + lời mời gửi tới
      c.loadSent(reset: true); // danh sách đã gửi (pending)
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<FriendsController>();
    final auth = context.watch<AuthController>();
    final currentCount = ctrl.friends.length;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Bạn bè của bạn'),
      ),
      body: RefreshIndicator(
        onRefresh: ctrl.refresh,
        color: AppColors.brandYellow,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            // Header + search
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$currentCount / 20 người bạn đã được bổ sung',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _SearchBar(
                      controller: _searchCtrl,
                      hint: 'Thêm một người bạn mới',
                      onChanged: context
                          .read<FriendsController>()
                          .onQueryChanged,
                    ),
                    const SizedBox(height: 8),
                    _SearchResult(),
                    const SizedBox(height: 16),
                    const _SectionTitle('Bạn bè của bạn'),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // Danh sách bạn bè
            if (ctrl.isLoading) const SliverToBoxAdapter(child: _LoadingList()),
            if (!ctrl.isLoading && ctrl.error != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Lỗi: ${ctrl.error}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              ),
            if (!ctrl.isLoading &&
                ctrl.error == null &&
                ctrl.friends.isNotEmpty)
              SliverList(
                delegate: SliverChildBuilderDelegate((context, i) {
                  final user = ctrl.friends[i];
                  return _FriendTile(
                    user: user,
                    onUnfriend: () async {
                      final ok = await context
                          .read<FriendsController>()
                          .unfriend(user);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            ok
                                ? 'Đã hủy kết bạn với ${user.fullname ?? user.email ?? 'người dùng'}'
                                : 'Không thể hủy kết bạn',
                          ),
                        ),
                      );
                    },
                  );
                }, childCount: ctrl.friends.length),
              ),

            // =========================
            // LỜI MỜI KẾT BẠN GỬI TỚI
            // =========================
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: const _SectionTitle('Lời mời kết bạn gửi tới bạn'),
              ),
            ),

            if (!ctrl.isLoading && ctrl.incomingRequests.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text('Hiện chưa có lời mời mới.'),
                ),
              ),

            if (ctrl.incomingRequests.isNotEmpty)
              SliverList(
                delegate: SliverChildBuilderDelegate((context, i) {
                  final item = ctrl.incomingRequests[i];
                  return _IncomingRequestTile(
                    item: item,
                    onAccept: () async {
                      final ok = await context
                          .read<FriendsController>()
                          .acceptRequest(item);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            ok
                                ? 'Đã chấp nhận ${item.requesterFullname}'
                                : 'Không thể chấp nhận lời mời',
                          ),
                        ),
                      );
                    },
                    onReject: () async {
                      final ok = await context
                          .read<FriendsController>()
                          .rejectIncoming(item);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            ok
                                ? 'Đã từ chối ${item.requesterFullname}'
                                : 'Không thể từ chối lời mời',
                          ),
                        ),
                      );
                    },
                  );
                }, childCount: ctrl.incomingRequests.length),
              ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
            // =========================
            // LỜI MỜI BẠN ĐÃ GỬI
            // =========================
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: const _SectionTitle('Lời mời bạn đã gửi'),
              ),
            ),

            if (!ctrl.isLoading && ctrl.sentRequests.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text('Bạn chưa gửi lời mời nào.'),
                ),
              ),

            if (ctrl.sentRequests.isNotEmpty)
              SliverList(
                delegate: SliverChildBuilderDelegate((context, i) {
                  final item = ctrl.sentRequests[i];
                  return _SentRequestTile(
                    item: item,
                    onCancel: () async {
                      final ok = await context
                          .read<FriendsController>()
                          .cancelSent(item.requestId); // gọi controller
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(ok ? 'Đã huỷ lời mời' : 'Huỷ thất bại'),
                        ),
                      );
                    },
                  );
                }, childCount: ctrl.sentRequests.length),
              ),

            // (tuỳ chọn) Nút tải thêm nếu còn trang
            if (ctrl.hasMoreSent)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: FilledButton(
                    onPressed: ctrl.isLoadingSent
                        ? null
                        : () => context.read<FriendsController>().loadSent(),
                    child: ctrl.isLoadingSent
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Tải thêm'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/* ================== UI widgets ================== */

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  const _SearchBar({
    required this.controller,
    required this.hint,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.textSecondary),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: AppColors.textSecondary),
                border: InputBorder.none,
                isCollapsed: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResult extends StatelessWidget {
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
        title: Text(user.fullname ?? user.email ?? 'Người dùng'),
        subtitle: Text(user.email ?? ''),
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

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text, {super.key});
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _FriendTile extends StatelessWidget {
  final UserDTO user;
  final VoidCallback? onUnfriend;
  const _FriendTile({required this.user, this.onUnfriend, super.key});

  @override
  Widget build(BuildContext context) {
    final url = user.image;
    final displayName = (user.fullname?.isNotEmpty ?? false)
        ? user.fullname!
        : (user.email ?? 'Người dùng');

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        radius: 26,
        backgroundColor: AppColors.background,
        backgroundImage: (url != null && url.isNotEmpty)
            ? NetworkImage(url)
            : null,
        child: (url == null || url.isEmpty)
            ? Text(
                _initials(displayName),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
      title: Text(
        displayName,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w800,
        ),
      ),
      // ✅ Nút X giống phần “incoming/sent”
      trailing: IconButton(
        tooltip: 'Hủy kết bạn',
        onPressed: onUnfriend,
        style: IconButton.styleFrom(
          backgroundColor: Colors.red.shade500,
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          minimumSize: const Size(40, 40),
        ),
        icon: const Icon(Icons.close_rounded),
      ),
    );
  }

  String _initials(String nameOrEmail) {
    final trimmed = nameOrEmail.trim();
    if (trimmed.isEmpty) return 'U';
    if (!trimmed.contains(' ') && trimmed.contains('@')) {
      final s = trimmed.split('@').first;
      return s.isEmpty
          ? 'U'
          : s.substring(0, s.length >= 2 ? 2 : 1).toUpperCase();
    }
    final parts = trimmed
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    final letters = [
      if (parts.isNotEmpty) parts[0][0],
      if (parts.length > 1) parts[1][0],
    ].join();
    return (letters.isEmpty ? 'U' : letters).toUpperCase();
  }
}

class _IncomingRequestTile extends StatelessWidget {
  final FriendRequestItemDTO item;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _IncomingRequestTile({
    super.key,
    required this.item,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = item.requesterAvatar;
    final name = item.requesterFullname.isNotEmpty
        ? item.requesterFullname
        : item.requesterEmail;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.background,
        backgroundImage: avatar.isNotEmpty ? NetworkImage(avatar) : null,
        child: avatar.isEmpty
            ? Text(
                _initials(name),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
      title: Text(
        name,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: const Text('đã gửi lời mời kết bạn'),
      trailing: Wrap(
        spacing: 8,
        children: [
          // ❌ Hủy: nền đỏ, icon trắng
          IconButton(
            onPressed: onReject,
            tooltip: 'Huỷ',
            style: IconButton.styleFrom(
              backgroundColor: Colors.red.shade500,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              minimumSize: const Size(40, 40), // chỉnh kích thước nút
            ),
            icon: const Icon(Icons.close_rounded),
          ),
          // ✅ Đồng ý: nền vàng (brand), icon trắng
          IconButton(
            onPressed: onAccept,
            tooltip: 'Đồng ý',
            style: IconButton.styleFrom(
              backgroundColor: AppColors.brandYellow,
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              minimumSize: const Size(40, 40),
            ),
            icon: const Icon(Icons.check_rounded),
          ),
        ],
      ),
    );
  }

  String _initials(String nameOrEmail) {
    final trimmed = nameOrEmail.trim();
    if (trimmed.isEmpty) return 'U';
    if (!trimmed.contains(' ') && trimmed.contains('@')) {
      final s = trimmed.split('@').first;
      return s.isEmpty
          ? 'U'
          : s.substring(0, s.length >= 2 ? 2 : 1).toUpperCase();
    }
    final parts = trimmed
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    final letters = [
      if (parts.isNotEmpty) parts[0][0],
      if (parts.length > 1) parts[1][0],
    ].join();
    return (letters.isEmpty ? 'U' : letters).toUpperCase();
  }
}

class _LoadingList extends StatelessWidget {
  const _LoadingList({super.key});
  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        4,
        (i) => const ListTile(
          leading: CircleAvatar(
            backgroundColor: AppColors.textSecondary,
            radius: 26,
          ),
          title: SizedBox(
            height: 12,
            child: DecoratedBox(
              decoration: BoxDecoration(color: AppColors.textSecondary),
            ),
          ),
          subtitle: SizedBox(
            height: 10,
            child: DecoratedBox(
              decoration: BoxDecoration(color: AppColors.textSecondary),
            ),
          ),
        ),
      ),
    );
  }
}

class _SentRequestTile extends StatelessWidget {
  final FriendRqSentItemDTO item;
  final VoidCallback onCancel;

  const _SentRequestTile({
    super.key,
    required this.item,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = item.targetAvatar;
    final name = (item.targetFullname.isNotEmpty)
        ? item.targetFullname
        : item.targetEmail;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: AppColors.background,
        backgroundImage: (avatar != null && avatar.isNotEmpty)
            ? NetworkImage(avatar)
            : null,
        child: (avatar == null || avatar.isEmpty)
            ? Text(
                _initials(name),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                ),
              )
            : null,
      ),
      title: Text(
        name,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: const Text('đã gửi lời mời kết bạn'),
      trailing: IconButton(
        tooltip: 'Huỷ lời mời',
        onPressed: onCancel,
        style: IconButton.styleFrom(
          backgroundColor: Colors.red.shade500,
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          minimumSize: const Size(40, 40),
        ),
        icon: const Icon(Icons.close_rounded),
      ),
    );
  }

  String _initials(String s) {
    final trimmed = s.trim();
    if (trimmed.isEmpty) return 'U';
    if (!trimmed.contains(' ') && trimmed.contains('@')) {
      final u = trimmed.split('@').first;
      return (u.isEmpty ? 'U' : u.substring(0, u.length >= 2 ? 2 : 1))
          .toUpperCase();
    }
    final parts = trimmed
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    final letters = [
      if (parts.isNotEmpty) parts[0][0],
      if (parts.length > 1) parts[1][0],
    ].join();
    return (letters.isEmpty ? 'U' : letters).toUpperCase();
  }
}
