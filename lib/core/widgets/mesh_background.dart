import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

enum MeshBackgroundIntensity { standard, strong }

/// Shared blue ambient backdrop for the app's non-immersive surfaces.
///
/// [MeshBackgroundIntensity.standard] keeps long dashboard/settings pages calm,
/// while [MeshBackgroundIntensity.strong] gives focused entry screens a more
/// prominent brand wash. Intro and Pattern Interrupt intentionally use their
/// own full-bleed art direction.
class MeshBackground extends StatelessWidget {
  final Widget child;
  final MeshBackgroundIntensity intensity;

  const MeshBackground({
    super.key,
    required this.child,
    this.intensity = MeshBackgroundIntensity.standard,
  });

  @override
  Widget build(BuildContext context) {
    final strong = intensity == MeshBackgroundIntensity.strong;
    return DecoratedBox(
      key: const ValueKey('app-blue-backdrop'),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: strong
              ? const [Color(0xFFC7EAF8), Color(0xFFD7E9FB), Color(0xFFEEF6FD)]
              : const [Color(0xFFD6EFF9), Color(0xFFE2EFFC), Color(0xFFF3F8FD)],
          stops: const [0, 0.5, 1],
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: strong ? -130 : -105,
            left: strong ? -110 : -90,
            child: _Blob(
              color: AppColors.sky.withValues(alpha: strong ? 0.24 : 0.16),
              size: strong ? 390 : 330,
            ),
          ),
          Positioned(
            top: strong ? -80 : -55,
            right: strong ? -130 : -105,
            child: _Blob(
              color: AppColors.navyLight.withValues(
                alpha: strong ? 0.14 : 0.09,
              ),
              size: strong ? 380 : 320,
            ),
          ),
          Positioned(
            bottom: strong ? -170 : -145,
            left: strong ? 30 : 80,
            child: _Blob(
              color: AppColors.skyLight.withValues(alpha: strong ? 0.55 : 0.38),
              size: strong ? 420 : 350,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  final Color color;
  final double size;
  const _Blob({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}
