import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Shared Gamblock-AI brand lockup for authentication entry points.
class AuthBrandLockup extends StatelessWidget {
  const AuthBrandLockup({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      header: true,
      label: 'Gamblock-AI',
      child: ExcludeSemantics(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/gamblock-1.png',
              key: const ValueKey('auth-brand-logo'),
              height: 72,
              fit: BoxFit.contain,
              excludeFromSemantics: true,
            ),
            const SizedBox(height: 8),
            Text.rich(
              key: const ValueKey('auth-brand-wordmark'),
              const TextSpan(
                children: [
                  TextSpan(
                    text: 'Gamblock',
                    style: TextStyle(
                      color: AppColors.navy,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  TextSpan(
                    text: '-AI',
                    style: TextStyle(
                      color: AppColors.crimson,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
