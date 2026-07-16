import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Shared Gamblock-AI brand lockup for authentication entry points.
class AuthBrandLockup extends StatelessWidget {
  const AuthBrandLockup({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset('assets/images/gamblock-1.png', height: 44),
        const SizedBox(width: 10),
        Text.rich(
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
        ),
      ],
    );
  }
}
