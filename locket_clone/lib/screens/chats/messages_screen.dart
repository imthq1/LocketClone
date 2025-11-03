import 'package:flutter/material.dart';
import 'package:locket_clone/services/application/friends_controller.dart';
import 'package:provider/provider.dart';
import 'package:locket_clone/theme/app_colors.dart';
import 'widgets/message_widgets.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<FriendsController>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textSecondary,
          ),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
        centerTitle: true,
        title: const Text(
          'Messages',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: RefreshIndicator(
        color: AppColors.brandYellow,
        backgroundColor: AppColors.background,
        onRefresh: ctrl.refresh,
        child: Builder(
          builder: (_) {
            if (ctrl.isLoading && ctrl.friends.isEmpty) {
              return const LoadingList(); // Dùng Widget
            }
            if (ctrl.error != null && ctrl.friends.isEmpty) {
              return ListView(
                children: [
                  const SizedBox(height: 120),
                  Center(
                    child: Text(
                      ctrl.error!,
                      style: const TextStyle(color: AppColors.textSecondary),
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
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: items.length,
              separatorBuilder: (_, __) => Divider(
                height: 1,
                color: AppColors.fieldBackground,
                indent: 72,
              ),
              itemBuilder: (_, i) => ChatRow(user: items[i]),
            );
          },
        ),
      ),
    );
  }
}
