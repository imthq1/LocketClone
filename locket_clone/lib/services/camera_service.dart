import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;

enum CameraPermissionState { initializing, granted, denied }

class CameraService {
  bool _isRequestingPermission = false;

  Future<CameraPermissionState> requestPermission() async {
    if (_isRequestingPermission) {
      final status = await Permission.camera.status;
      return status.isGranted
          ? CameraPermissionState.granted
          : CameraPermissionState.denied;
    }

    try {
      _isRequestingPermission = true;
      final status = await Permission.camera.request();
      if (status.isGranted) {
        return CameraPermissionState.granted;
      }
      return CameraPermissionState.denied;
    } catch (e) {
      debugPrint('Lỗi khi request permission: $e');
      return CameraPermissionState.denied;
    } finally {
      _isRequestingPermission = false;
    }
  }

  /// 2. Mở cài đặt ứng dụng nếu người dùng từ chối vĩnh viễn
  Future<void> openAppSettings() async {
    await permission_handler.openAppSettings();
  }

  /// 3. Khởi tạo CameraController
  Future<CameraController?> initializeController({
    bool useFrontCamera = true,
  }) async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        debugPrint('Không tìm thấy camera nào.');
        return null;
      }

      CameraDescription? selectedCamera;
      final lensDirection = useFrontCamera
          ? CameraLensDirection.front
          : CameraLensDirection.back;

      for (var cam in cameras) {
        if (cam.lensDirection == lensDirection) {
          selectedCamera = cam;
          break;
        }
      }
      selectedCamera ??= cameras.first;

      final controller = CameraController(
        selectedCamera,
        ResolutionPreset.max,
        enableAudio: false,
      );

      await controller.initialize();
      return controller;
    } catch (e) {
      debugPrint('Lỗi khởi tạo camera: $e');
      return null;
    }
  }
}
