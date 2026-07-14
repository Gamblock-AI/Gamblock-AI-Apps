import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Pastel mesh background (mirrors the website `bg-mesh`): a soft cyan->azure
/// gradient wash with two faint radial glows. Use as a full-screen backdrop or
/// a rounded header panel.
class MeshBackground extends StatelessWidget {
  final Widget child;
  const MeshBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: AppColors.meshGradient),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            left: -60,
            child: _Blob(
              color: AppColors.skyLight.withValues(alpha: 0.55),
              size: 240,
            ),
          ),
          Positioned(
            top: -40,
            right: -70,
            child: _Blob(
              color: AppColors.azure.withValues(alpha: 0.7),
              size: 260,
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
