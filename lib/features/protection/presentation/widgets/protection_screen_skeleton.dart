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
        Row(
          children: [
            const SkeletonBox(
              width: 48,
              height: 48,
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonBox(width: 120, height: 11),
                  SizedBox(height: 8),
                  SkeletonBox(width: 160, height: 15),
                  SizedBox(height: 8),
                  SkeletonBox(width: 100, height: 11),
                ],
              ),
            ),
            const SkeletonBox(
              width: 40,
              height: 40,
              borderRadius: BorderRadius.all(Radius.circular(999)),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            const SkeletonBox(
              width: 110,
              height: 36,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            const SizedBox(width: 12),
            const SkeletonBox(
              width: 100,
              height: 36,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            const SizedBox(width: 12),
            const SkeletonBox(
              width: 110,
              height: 36,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ],
        ),
        const SizedBox(height: 20),
        SkeletonBox(
          width: double.infinity,
          height: 180,
          borderRadius: cardRadius,
        ),
        const SizedBox(height: 16),
        SkeletonBox(
          width: double.infinity,
          height: 110,
          borderRadius: cardRadius,
        ),
        const SizedBox(height: 16),
        SkeletonBox(
          width: double.infinity,
          height: 48,
          borderRadius: BorderRadius.circular(AppRadius.pill),
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
