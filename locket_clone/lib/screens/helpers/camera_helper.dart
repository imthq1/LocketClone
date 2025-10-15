import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:locket_clone/screens/home/send_capture.dart';
import 'package:locket_clone/services/application/friends_controller.dart';
import 'package:provider/provider.dart';

/// Helper dùng để xử lý camera & điều hướng.
/// - Chụp ảnh, tắt camera trước khi push.
/// - Điều hướng sang trang Chat hoặc SendToScreen.
/// - Re-init camera khi quay lại.
class CameraHelper {
  static bool _isCapturing = false;

  static Future<void> capture({
    required BuildContext context,
    required CameraController controller,
    required Future<void> Function(CameraDescription desc) onReinitCamera,
  }) async {
    if (!controller.value.isInitialized) return;
    if (_isCapturing || controller.value.isTakingPicture) return;

    _isCapturing = true;
    final currentDesc = controller.description;

    try {
      // Chụp ảnh
      final x = await controller.takePicture();
      final path = x.path;

      // Tắt camera ngay
      try {
        await controller.dispose();
      } catch (_) {}
      if (Platform.isAndroid) {
        await Future.delayed(const Duration(milliseconds: 120));
      }

      if (!context.mounted) return;
      await Navigator.of(context, rootNavigator: true)
          .push(
            MaterialPageRoute(builder: (_) => SendToScreen(imagePath: path)),
          )
          .then((_) async {
            if (context.mounted) {
              await onReinitCamera(currentDesc);
            }
          });
    } catch (e, s) {
      debugPrint('CameraHelper.capture error: $e\n$s');
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Không thể chụp/gửi ảnh')));
      }
    } finally {
      _isCapturing = false;
    }
  }

  static Future<void> goToMessages({
    required BuildContext context,
    required CameraController? controller,
    required Future<void> Function(CameraDescription desc) onReinitCamera,
  }) async {
    final desc = controller?.description;

    try {
      // Dừng/giải phóng camera trước khi chuyển màn
      try {
        await controller?.dispose();
      } catch (_) {}

      if (Platform.isAndroid) {
        await Future.delayed(const Duration(milliseconds: 120));
      }

      if (!context.mounted) return;

      final friendsCtrl = context.read<FriendsController>();
      await friendsCtrl.load();
      await Navigator.pushNamed(context, '/chat');

      // Khởi tạo lại camera khi quay về
      if (!context.mounted) return;
      if (desc != null) await onReinitCamera(desc);
    } catch (e, s) {
      debugPrint('CameraHelper.goToMessages error: $e\n$s');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể mở danh sách chat')),
        );
      }
    }
  }
}
