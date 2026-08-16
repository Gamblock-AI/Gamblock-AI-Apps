import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/theme/app_colors.dart';

/// Renders the calm looping intervention video as a muted background layer,
/// adapting dynamically between mobile (`intervention-android.mp4`) and
/// desktop/wide screen (`intervention-desktop.mp4`).
///
/// Features:
/// - Seamless looping with zero audio volume.
/// - Full-bleed `BoxFit.cover` scaling with a calm dark gradient scrim.
/// - Respects reduced motion (`MediaQuery.disableAnimationsOf`).
/// - Graceful silent fallback to [AppColors.calmDarkGradient] during loading
///   or in unsupported headless/test environments.
class PatternVideoBackground extends StatefulWidget {
  const PatternVideoBackground({super.key, required this.child});

  final Widget child;

  @override
  State<PatternVideoBackground> createState() => _PatternVideoBackgroundState();
}

class _PatternVideoBackgroundState extends State<PatternVideoBackground>
    with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  String? _loadedAsset;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkAndInitVideo();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_controller == null || !_isInitialized) return;
    if (state == AppLifecycleState.resumed) {
      if (!MediaQuery.disableAnimationsOf(context)) {
        _controller?.play();
      }
    } else if (state == AppLifecycleState.paused) {
      _controller?.pause();
    }
  }

  void _checkAndInitVideo() {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    if (disableAnimations) {
      _controller?.pause();
      return;
    }

    final isWide = MediaQuery.sizeOf(context).width >= 720;
    final isDesktopPlatform = !kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux);
    final targetAsset = (isWide || isDesktopPlatform)
        ? 'assets/videos/intervention-desktop.mp4'
        : 'assets/videos/intervention-android.mp4';

    if (_loadedAsset == targetAsset && _controller != null) {
      if (_isInitialized && !_controller!.value.isPlaying) {
        _controller!.play();
      }
      return;
    }

    _loadedAsset = targetAsset;
    final oldController = _controller;
    _controller = null;
    _isInitialized = false;

    oldController?.dispose();

    final newController = VideoPlayerController.asset(targetAsset);
    _controller = newController;

    newController
        .initialize()
        .then((_) {
          if (!mounted || _controller != newController) return;
          newController.setLooping(true);
          newController.setVolume(0.0);
          if (!MediaQuery.disableAnimationsOf(context)) {
            newController.play();
          }
          setState(() {
            _isInitialized = true;
          });
        })
        .catchError((_) {
          if (!mounted) return;
          setState(() {
            _isInitialized = false;
          });
        });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    final showVideo = !disableAnimations && _isInitialized && _controller != null;

    return Stack(
      fit: StackFit.expand,
      children: [
        // Base dark calm backdrop
        Container(
          decoration: const BoxDecoration(gradient: AppColors.calmDarkGradient),
        ),

        // Video Layer with gentle fade-in
        if (_controller != null && _isInitialized)
          AnimatedOpacity(
            opacity: showVideo ? 1.0 : 0.0,
            duration: disableAnimations
                ? Duration.zero
                : const Duration(milliseconds: 500),
            child: SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller!.value.size.width,
                  height: _controller!.value.size.height,
                  child: VideoPlayer(_controller!),
                ),
              ),
            ),
          ),

        // Ambient vignette scrim overlay: protects text legibility without obscuring video
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: showVideo ? 0.30 : 0.45),
                Colors.black.withValues(alpha: showVideo ? 0.15 : 0.40),
                const Color(0xFF09090B).withValues(alpha: showVideo ? 0.55 : 0.65),
              ],
              stops: const [0.0, 0.45, 1.0],
            ),
          ),
        ),

        // Foreground content
        widget.child,
      ],
    );
  }
}
