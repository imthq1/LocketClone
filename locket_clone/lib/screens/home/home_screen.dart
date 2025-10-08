import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:locket_clone/screens/home/send_capture.dart';
import 'package:provider/provider.dart';
import 'package:locket_clone/services/auth/application/auth_controller.dart';

/// NOTE
/// - Add `camera` to pubspec.yaml
///   camera: ^0.10.6+5 (or latest)
/// - On iOS add the following to ios/Runner/Info.plist:
///   <key>NSCameraUsageDescription</key>
///   <string>Your photo will be used for posts.</string>
/// - On Android ensure camera permission is requested in AndroidManifest.xml
///   <uses-permission android:name="android.permission.CAMERA"/>
///
/// This screen mimics Locket's capture UI, with rounded preview, big shutter,
/// friends pill, gallery icon, flip camera, flash toggle, and a History row.
/// It also keeps your requirement: a Logout icon in the AppBar.

class HomeScreen extends StatefulWidget {
  const HomeScreen();

  @override
  State<HomeScreen> createState() => _CaptureBodyState();
}

class _CaptureBodyState extends State<HomeScreen> with WidgetsBindingObserver {
  CameraController? _controller;
  List<CameraDescription> _cameras = const [];
  bool _hasFlash = false;
  bool _flashOn = false;
  double _zoomLevel = 1.0;
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (state == AppLifecycleState.inactive) {
      controller.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initSelectedCamera(controller.description);
    }
  }

  Future<void> _initCamera() async {
    try {
      _cameras = await availableCameras();
      final preferBack = _cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => _cameras.first,
      );
      await _initSelectedCamera(preferBack);
    } catch (e) {
      debugPrint('Camera init error: $e');
      if (mounted) setState(() {});
    }
  }

  Future<void> _initSelectedCamera(CameraDescription description) async {
    final ctrl = CameraController(
      description,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isIOS
          ? ImageFormatGroup.bgra8888
          : ImageFormatGroup.yuv420,
    );
    try {
      await ctrl.initialize();
      _zoomLevel = 1.0;
    } catch (e) {
      debugPrint('Camera initialize error: $e');
    }
    if (!mounted) return;
    setState(() {
      _controller?.dispose();
      _controller = ctrl;
    });
  }

  Future<void> _toggleCamera() async {
    if (_cameras.isEmpty) return;
    final current = _controller?.description;
    if (current == null) return;
    final nextIndex = (_cameras.indexOf(current) + 1) % _cameras.length;
    await _initSelectedCamera(_cameras[nextIndex]);
  }

  Future<void> _toggleFlash() async {
    final c = _controller;
    if (c == null || !_hasFlash) return;
    _flashOn = !_flashOn;
    await c.setFlashMode(_flashOn ? FlashMode.torch : FlashMode.off);
    if (mounted) setState(() {});
  }

  Future<void> _capture() async {
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    if (_isCapturing || c.value.isTakingPicture) return; // chặn spam
    _isCapturing = true;
    try {
      // Tùy máy Android, pause preview giúp giải phóng buffer
      if (c.value.isPreviewPaused == false) {
        await c.pausePreview();
      }

      final file = await c.takePicture();

      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => SendToScreen(imagePath: file.path)),
        );
      }
    } finally {
      try {
        // resume lại preview sau khi chụp xong
        if (c.value.isPreviewPaused == true) {
          await c.resumePreview();
        }
      } catch (_) {}
      _isCapturing = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    final isReady = c?.value.isInitialized == true;
    final auth = context.watch<AuthController>();
    final user = auth.user;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Top overlay like Locket (avatar, friends pill, chat)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Row(
                children: [
                  const _RoundAvatar(),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: _PillButton(
                        icon: Icons.group,
                        label: (user?.friend?.sumUser ?? 0).toString(),
                        onTap: () {},
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _RoundIcon(icon: Icons.chat_bubble_outline, onTap: () {}),
                  const SizedBox(width: 1),
                  IconButton(
                    tooltip: 'Logout',
                    icon: const Icon(Icons.logout),
                    onPressed: () async {
                      await context.read<AuthController>().logout();
                      if (context.mounted) {
                        Navigator.of(
                          context,
                        ).pushNamedAndRemoveUntil('/login', (route) => false);
                      }
                    },
                  ),
                ],
              ),
            ),

            // Center camera with rounded rectangle
            Align(
              alignment: Alignment.center,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: AspectRatio(
                  aspectRatio: 3 / 4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: Container(
                      color: Colors.black,
                      child: isReady
                          ? Stack(
                              fit: StackFit.expand,
                              children: [
                                CameraPreview(c!),
                                // Flash & zoom badges
                                Positioned(
                                  left: 12,
                                  top: 12,
                                  child: _BadgeIcon(
                                    icon: Icons.flash_on,
                                    enabled: _hasFlash,
                                    isActive: _flashOn,
                                    onTap: _toggleFlash,
                                  ),
                                ),
                                Positioned(
                                  right: 12,
                                  top: 12,
                                  child: _ZoomBadge(
                                    level: _zoomLevel,
                                    onTap: () async {
                                      // Toggle 1x / 2x if supported
                                      final maxZoom = await c.getMaxZoomLevel();
                                      final newLevel =
                                          (_zoomLevel - 1.0).abs() < 0.1 &&
                                              maxZoom >= 2.0
                                          ? 2.0
                                          : 1.0;
                                      await c.setZoomLevel(newLevel);
                                      setState(() => _zoomLevel = newLevel);
                                    },
                                  ),
                                ),
                              ],
                            )
                          : _CameraPlaceholder(),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom controls
            Positioned(
              left: 0,
              right: 0,
              bottom: 28,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _RoundIcon(
                        icon: Icons.photo_library_outlined,
                        onTap: () {},
                      ),
                      _ShutterButton(onTap: _capture),
                      _RoundIcon(
                        icon: Icons.cameraswitch_rounded,
                        onTap: _toggleCamera,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const _HistoryRow(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CameraPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF101010), Color(0xFF202020)],
        ),
      ),
      child: const Center(
        child: Text(
          'Đang chuẩn bị camera…',
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}

class _RoundAvatar extends StatelessWidget {
  const _RoundAvatar();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24),
        image: const DecorationImage(
          fit: BoxFit.cover,
          image: AssetImage(
            'assets/sample_avatar.jpg',
          ), // replace with NetworkImage if you have
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  const _PillButton({required this.icon, required this.label, this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white10,
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _RoundIcon({required this.icon, this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white10,
          border: Border.all(color: Colors.white24),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

class _BadgeIcon extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final bool isActive;
  final VoidCallback? onTap;
  const _BadgeIcon({
    required this.icon,
    this.enabled = true,
    this.isActive = false,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.4,
      child: GestureDetector(
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black45,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: Icon(
            icon,
            color: isActive ? Colors.amber : Colors.white,
            size: 18,
          ),
        ),
      ),
    );
  }
}

class _ZoomBadge extends StatelessWidget {
  final double level;
  final VoidCallback? onTap;
  const _ZoomBadge({required this.level, this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black45,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Text(
          '${level.toStringAsFixed(0)}x',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _ShutterButton extends StatelessWidget {
  final VoidCallback? onTap;
  const _ShutterButton({this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 82,
        height: 82,
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.amber, width: 3),
          color: Colors.white10,
        ),
        child: Container(
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {},
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 32,
              height: 32,
              color: Colors.white24,
              child: const Icon(Icons.image, color: Colors.white, size: 18),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'History',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 6),
          const Icon(Icons.expand_more, color: Colors.white70, size: 20),
        ],
      ),
    );
  }
}
