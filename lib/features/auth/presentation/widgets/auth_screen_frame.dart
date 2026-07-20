import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/language_toggle_button.dart';

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
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 48, 24, 32),
                child: content,
              ),
            ),
            const Positioned(
              top: 12,
              left: 16,
              child: LanguageToggleButton(),
            ),
          ],
        ),
      ),
    );
  }
}
