import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Blue-tinted shimmer placeholder for branded loading states.
class SkeletonBox extends StatefulWidget {
  final double width;
  final double height;
  final BorderRadius borderRadius;

  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
  });

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1100),
      vsync: this,
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _controller.value = 0.5;
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final phase = (_controller.value * 2) - 1;
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(-1.8 + phase, -0.25),
              end: Alignment(0.2 + phase, 0.25),
              colors: [
                AppColors.azure.withValues(alpha: 0.72),
                Colors.white.withValues(alpha: 0.9),
                AppColors.skyLight.withValues(alpha: 0.58),
              ],
            ),
            borderRadius: widget.borderRadius,
            border: Border.all(color: Colors.white.withValues(alpha: 0.78)),
          ),
        );
      },
    );
  }
}
