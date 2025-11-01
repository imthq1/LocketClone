import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:locket_clone/services/application/friends_controller.dart';
import 'package:locket_clone/theme/app_colors.dart';
import 'barrels/tiles.dart';
import 'barrels/widget.dart';

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
    final currentCount = ctrl.friends.length;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
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
                    FriendSearchBar(
                      controller: _searchCtrl,
                      hint: 'Thêm một người bạn mới',
                      onChanged: context
                          .read<FriendsController>()
                          .onQueryChanged,
                    ),
                    const SizedBox(height: 8),
                    SearchResult(),
                    const SizedBox(height: 16),
                    const SectionTitle('Bạn bè của bạn'),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),

            // Danh sách bạn bè
            if (ctrl.isLoading) const SliverToBoxAdapter(child: LoadingList()),
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
                  return FriendTile(
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
                                ? 'Đã hủy kết bạn với ${user.fullname}'
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
                child: const SectionTitle('Lời mời kết bạn gửi tới bạn'),
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
                  return IncomingRequestTile(
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
                child: const SectionTitle('Lời mời bạn đã gửi'),
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
                  return SentRequestTile(
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
