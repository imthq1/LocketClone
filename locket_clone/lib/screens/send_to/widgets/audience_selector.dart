import 'package:flutter/material.dart';
import 'package:locket_clone/screens/send_to/send_to_controller.dart';
import 'package:locket_clone/theme/app_colors.dart';
import 'package:provider/provider.dart';

class AudienceSelector extends StatelessWidget {
  const AudienceSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SendToController>();
    final recipients = controller.recipients;
    final selectedIds = controller.selectedIds;

    if (recipients.length <= 1) {
      return const Padding(
        padding: EdgeInsets.only(bottom: 24.0),
        child: Text(
          'Chưa có bạn bè — sẽ đăng cho tất cả',
          style: TextStyle(color: Colors.white38, fontSize: 12),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: SizedBox(
        height: 84,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: recipients.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            final r = recipients[index];
            final bool isSelected = selectedIds.contains(r.id);

            return _AudienceButton(
              recipient: r,
              isSelected: isSelected,
              onTap: () => controller.toggleRecipient(r.id),
            );
          },
        ),
      ),
    );
  }
}

class _AudienceButton extends StatelessWidget {
  final Recipient recipient;
  final bool isSelected;
  final VoidCallback? onTap;

  const _AudienceButton({
    required this.recipient,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final avatarUrl = (recipient.avatarUrl ?? '').trim();

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.brandYellow : Colors.white24,
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white12,
              backgroundImage: avatarUrl.isNotEmpty
                  ? NetworkImage(avatarUrl)
                  : null,
              child: (avatarUrl.isEmpty && !recipient.isAll)
                  ? Text(
                      recipient.initial,
                      style: const TextStyle(color: Colors.white),
                    )
                  : (recipient.isAll
                        ? const Icon(
                            Icons.people,
                            color: Colors.white,
                            size: 22,
                          )
                        : null),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 64,
            child: Text(
              recipient.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected
                    ? AppColors.brandYellow
                    : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
