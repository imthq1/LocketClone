import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:locket_clone/screens/home/widgets/camera_controls.dart';
import 'package:locket_clone/screens/home/widgets/home_bottom_bar.dart';
import 'package:locket_clone/screens/home/widgets/permission_denied_view.dart';
import 'package:locket_clone/screens/send_to/send_to_screen.dart';
import 'package:locket_clone/services/camera_service.dart';
import 'package:locket_clone/theme/app_colors.dart';
import 'package:permission_handler/permission_handler.dart'
    as permission_handler;

class CameraView extends StatefulWidget {
  final VoidCallback? onHistoryPressed;

  const CameraView({super.key, this.onHistoryPressed});

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with WidgetsBindingObserver {
  final CameraService _cameraService = CameraService();
  CameraController? _controller;
  CameraPermissionState _permissionState = CameraPermissionState.initializing;
  bool _isFrontCamera = true;
  bool _isInitializing = false;
  bool _isFlashOn = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _controller;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    if (_isInitializing) return;
    setState(() {
      _isInitializing = true;
      _permissionState = CameraPermissionState.initializing;
    });

    try {
      final perm = await _cameraService.requestPermission();
      if (perm == CameraPermissionState.denied) {
        if (mounted) setState(() => _permissionState = perm);
        return;
      }

      final ctrl = await _cameraService.initializeController(
        useFrontCamera: _isFrontCamera,
      );

      if (ctrl == null) {
        if (mounted) {
          setState(() => _permissionState = CameraPermissionState.denied);
        }
        return;
      }

      if (mounted) {
        setState(() {
          _controller = ctrl;
          _permissionState = CameraPermissionState.granted;
          _isFlashOn = false;
          _controller!.setFlashMode(FlashMode.off);
        });
      }
    } catch (e) {
      debugPrint('Lỗi _initializeCamera: $e');
      if (mounted) {
        setState(() => _permissionState = CameraPermissionState.denied);
      }
    } finally {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    }
  }

  Future<void> _onGrantPermission() async {
    await permission_handler.openAppSettings();
  }

  Future<void> _flipCamera() async {
    if (_isInitializing) return;

    if (_isFlashOn) {
      await _toggleFlash();
    }

    await _controller?.dispose();
    _controller = null;

    _isFrontCamera = !_isFrontCamera;
    await _initializeCamera();
  }

  Future<void> _takePicture() async {
    if (_isInitializing ||
        _controller == null ||
        !_controller!.value.isInitialized) {
      return;
    }

    setState(() => _isInitializing = true);

    try {
      final XFile imageFile = await _controller!.takePicture();

      if (!mounted) return;

      if (_isFlashOn) {
        await _toggleFlash();
      }

      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => SendToScreen(imagePath: imageFile.path),
        ),
      );
    } catch (e) {
      debugPrint('Lỗi chụp ảnh: $e');
    } finally {
      if (mounted) {
        setState(() => _isInitializing = false);
      }
    }
  }

  Future<void> _toggleFlash() async {
    if (_isInitializing || _controller == null) return;

    final bool nextFlashState = !_isFlashOn;

    try {
      if (nextFlashState) {
        await _controller!.setFlashMode(FlashMode.torch);
      } else {
        await _controller!.setFlashMode(FlashMode.off);
      }
      setState(() {
        _isFlashOn = nextFlashState;
      });
    } catch (e) {
      if (kDebugMode) {
        print('Không thể set FlashMode: $e');
      }
      setState(() {
        _isFlashOn = false;
      });
    }
  }

  Widget _buildCameraView() {
    final bool isLoading =
        _permissionState == CameraPermissionState.initializing ||
        _isInitializing;
    final bool isDenied = _permissionState == CameraPermissionState.denied;
    final bool isGranted = _permissionState == CameraPermissionState.granted;
    final ctrl = _controller;

    Widget cameraPreviewWidget = Container();
    if (isGranted && ctrl != null && ctrl.value.isInitialized) {
      final previewSize = ctrl.value.previewSize;
      if (previewSize != null) {
        cameraPreviewWidget = FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: previewSize.height,
            height: previewSize.width,
            child: CameraPreview(ctrl),
          ),
        );
      }
    }

    Widget? overlayWidget;
    if (isLoading) {
      overlayWidget = const Center(
        child: CircularProgressIndicator(color: AppColors.brandYellow),
      );
    } else if (isDenied) {
      overlayWidget = PermissionDeniedView(onPressed: _onGrantPermission);
    } else if (isGranted && (ctrl == null || !ctrl.value.isInitialized)) {
      overlayWidget = PermissionDeniedView(onPressed: _initializeCamera);
    } else if (isGranted && ctrl != null && ctrl.value.previewSize == null) {
      overlayWidget = const Center(
        child: Text("Không thể lấy kích thước camera"),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(32.0),
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Container(
          color: AppColors.fieldBackground,
          child: Stack(
            fit: StackFit.expand,
            children: [
              cameraPreviewWidget,
              if (overlayWidget != null) overlayWidget,
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                const SizedBox(height: 70),
                _buildCameraView(),
                Padding(
                  padding: const EdgeInsets.only(top: 70),
                  child: CameraControls(
                    onFlashPressed: _toggleFlash,
                    onShutterPressed: _takePicture,
                    onFlipPressed: _flipCamera,
                    isFlashOn: _isFlashOn,
                  ),
                ),
                const Spacer(),
                HomeBottomBar(onHistoryPressed: widget.onHistoryPressed),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
