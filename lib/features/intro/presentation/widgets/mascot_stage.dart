import 'package:flutter/material.dart';

import '../../../../core/feedback/haptics.dart';
import '../../../../core/theme/app_colors.dart';

/// The mascot composition for an intro slide: a soft radial color blob and a
/// gentle ground shadow anchor the Gami artwork so the white area never feels
/// empty. The mascot idles with a slow float and playfully bounces when tapped.
class MascotStage extends StatefulWidget {
  final String asset;
  final String fallbackAsset;
  final double mascotWidth;
  final Color accent;

  const MascotStage({
    super.key,
    required this.asset,
    required this.mascotWidth,
    required this.accent,
    this.fallbackAsset = 'assets/images/gami.webp',
  });

  @override
  State<MascotStage> createState() => _MascotStageState();
}

class _MascotStageState extends State<MascotStage>
    with TickerProviderStateMixin {
  late final AnimationController _floatCtrl;
  late final Animation<double> _float;
  late final AnimationController _bounceCtrl;
  late final Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    );
    _float = CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut);
    _bounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
      value: 1.0,
    );
    _bounce = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _bounceCtrl, curve: Curves.elasticOut));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _floatCtrl.stop();
      _floatCtrl.value = 0;
    } else if (!_floatCtrl.isAnimating) {
      _floatCtrl.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _bounceCtrl.dispose();
    super.dispose();
  }

  void _handleTap() {
    Haptics.light();
    if (!MediaQuery.disableAnimationsOf(context)) {
      _bounceCtrl.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final blobDiameter = widget.mascotWidth * 1.55;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _handleTap,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          // Soft color halo that anchors the mascot on the white canvas.
          Container(
            width: blobDiameter,
            height: blobDiameter,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  widget.accent.withValues(alpha: 0.20),
                  widget.accent.withValues(alpha: 0.0),
                ],
                stops: const [0.35, 1.0],
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: Listenable.merge([_float, _bounce]),
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, -7 * _float.value),
                    child: Transform.scale(scale: _bounce.value, child: child),
                  );
                },
                child: Image.asset(
                  widget.asset,
                  width: widget.mascotWidth,
                  fit: BoxFit.contain,
                  excludeFromSemantics: true,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    widget.fallbackAsset,
                    width: widget.mascotWidth,
                    fit: BoxFit.contain,
                    excludeFromSemantics: true,
                    filterQuality: FilterQuality.high,
                  ),
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -14),
                child: Container(
                  width: widget.mascotWidth * 0.6,
                  height: 18,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.all(
                      Radius.elliptical(widget.mascotWidth * 0.3, 9),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.navy.withValues(alpha: 0.18),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
