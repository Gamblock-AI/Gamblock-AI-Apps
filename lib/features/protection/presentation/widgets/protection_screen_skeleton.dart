import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/skeleton_box.dart';

/// Loading placeholder mirroring the dashboard content blocks so the layout
/// does not jump when the protection status arrives.
class ProtectionScreenSkeleton extends StatelessWidget {
  const ProtectionScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final cardRadius = BorderRadius.circular(AppRadius.lg);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SkeletonBox(
          width: double.infinity,
          height: 180,
          borderRadius: cardRadius,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: SkeletonBox(
                width: double.infinity,
                height: 48,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: SkeletonBox(
                width: double.infinity,
                height: 48,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        SkeletonBox(
          width: double.infinity,
          height: 150,
          borderRadius: cardRadius,
        ),
      ],
    );
  }
}
