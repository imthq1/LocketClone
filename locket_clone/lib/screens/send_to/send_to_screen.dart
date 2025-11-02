import 'package:flutter/material.dart';
import 'package:locket_clone/screens/send_to/send_to_controller.dart';
import 'package:locket_clone/screens/send_to/widgets/picture_preview.dart';
import 'package:locket_clone/screens/send_to/widgets/send_controls.dart';
import 'package:locket_clone/screens/send_to/widgets/send_to_top_bar.dart';
import 'package:locket_clone/services/application/auth_controller.dart';
import 'package:locket_clone/services/application/post_controller.dart';
import 'package:locket_clone/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:gal/gal.dart';
import 'package:flutter/foundation.dart';

class SendToScreen extends StatelessWidget {
  final String imagePath;
  const SendToScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (ctx) => SendToController(
        ctx.read<AuthController>(),
        ctx.read<PostController>(),
      ),
      child: _SendToScreenView(imagePath: imagePath),
    );
  }
}

class _SendToScreenView extends StatefulWidget {
  final String imagePath;
  const _SendToScreenView({required this.imagePath});

  @override
  State<_SendToScreenView> createState() => _SendToScreenViewState();
}

class _SendToScreenViewState extends State<_SendToScreenView> {
  bool _isDownloading = false;
  bool _isDownloadSuccess = false;

  void _onCancel(BuildContext context) {
    Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
  }

  Future<void> _onSend(BuildContext context) async {
    final controller = context.read<SendToController>();
    final bool success = await controller.sendPost(widget.imagePath);

    if (!context.mounted) return;
    if (success) {
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } else {
      final error = controller.error ?? 'Đã xảy ra lỗi không xác định';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error.withValues(alpha: 0.9),
        ),
      );
    }
  }

  Future<void> _showEditMessageSheet(BuildContext context) async {
    final controller = context.read<SendToController>();
    final textController = TextEditingController(text: controller.caption);

    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
            top: 16,
            left: 16,
            right: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Thêm một tin nhắn',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: textController,
                maxLength: 140,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  counterStyle: const TextStyle(color: Colors.white54),
                  hintText: 'Nói gì đó…',
                  hintStyle: const TextStyle(color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.white24),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(
                    ctx,
                    textController.text.trim().isEmpty
                        ? null
                        : textController.text.trim(),
                  ),
                  child: const Text('Xong'),
                ),
              ),
            ],
          ),
        );
      },
    );

    controller.setCaption(result);
  }

  Future<void> _onDownload() async {
    if (_isDownloading || _isDownloadSuccess) return;

    setState(() => _isDownloading = true);

    try {
      // 1. Tạo một Future cho việc lưu ảnh
      final saveOperation = Gal.putImage(widget.imagePath, album: 'Locket');

      // 2. Tạo một Future cho khoảng trễ tối thiểu
      final minDelay = Future.delayed(
        const Duration(seconds: 0, milliseconds: 600),
      );

      // 3. Chờ cả hai hoàn thành
      await Future.wait([saveOperation, minDelay]);

      // 4. Đặt cờ thành công
      if (!mounted) return;
      setState(() {
        _isDownloadSuccess = true;
      });
    } catch (e) {
      // 5. Xử lý lỗi
      if (kDebugMode) {
        print('Lỗi khi lưu ảnh: $e');
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lưu ảnh thất bại. Vui lòng thử lại. $e'),
          backgroundColor: AppColors.error.withValues(alpha: 0.9),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isDownloading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final caption = context.watch<SendToController>().caption;
    final isSending = context.watch<SendToController>().isSending;
    final isLoadingOverlay = isSending || _isDownloading;

    return AbsorbPointer(
      absorbing: isLoadingOverlay,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Stack(
            children: [
              // 1. Top Bar
              Align(
                alignment: Alignment.topCenter,
                child: SendToTopBar(
                  onDownloadPressed: _onDownload,
                  isDownloading: _isDownloading,
                  isDownloadSuccess: _isDownloadSuccess,
                ),
              ),
              Column(
                children: [
                  const SizedBox(height: 80),
                  // 2. Khung ảnh
                  PicturePreview(
                    imagePath: widget.imagePath,
                    caption: caption,
                    onAddMessagePressed: () => _showEditMessageSheet(context),
                  ),
                  // 3. Các nút điều khiển
                  Padding(
                    padding: const EdgeInsets.only(top: 54.0),
                    child: SendControls(
                      onCancelPressed: () => _onCancel(context),
                      onSendPressed: () => _onSend(context),
                      cancelIconSize: 30,
                      sendIconSize: 80,
                    ),
                  ),
                ],
              ),

              if (isLoadingOverlay)
                Container(
                  color: Colors.black54,
                  alignment: Alignment.center,
                  child: const CircularProgressIndicator(
                    color: AppColors.brandYellow,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
