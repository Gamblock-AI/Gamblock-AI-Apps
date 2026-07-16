import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';

/// Applies the shared safe-area, surface, and width constraints for auth forms.
class AuthScreenFrame extends StatelessWidget {
  const AuthScreenFrame({super.key, required this.child, this.animate = false});

  final Widget child;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final constrainedChild = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: child,
    );
    final content = animate
        ? constrainedChild
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.04, end: 0, curve: Curves.easeOutCubic)
        : constrainedChild;
    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: content,
          ),
        ),
      ),
    );
  }
}
