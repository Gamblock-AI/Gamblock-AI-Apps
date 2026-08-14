import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/skeleton_box.dart';

/// Loading placeholder mirroring the dashboard content blocks so the layout
/// does not jump when the protection status arrives.
class ProtectionScreenSkeleton extends StatelessWidget {
  const ProtectionScreenSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final bannerRadius = BorderRadius.circular(AppRadius.banner);
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final actionHeight = textScale > 1.2 ? 156.0 : 136.0;
        final sensorHeight = textScale > 1.2 ? 194.0 : 174.0;
        final showActionsInRow = constraints.maxWidth >= 320;
        final sensorColumnCount = constraints.maxWidth >= 900 ? 4 : 2;
        const gap = 10.0;
        final sensorWidth =
            (constraints.maxWidth - (gap * (sensorColumnCount - 1))) /
            sensorColumnCount;

        return Column(
          key: const ValueKey('protection-dashboard-skeleton'),
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SkeletonBox(
              width: double.infinity,
              height: constraints.maxWidth >= 720 ? 252 : 268,
              borderRadius: bannerRadius,
            ),
            const SizedBox(height: 28),
            const SkeletonBox(width: 112, height: 18),
            const SizedBox(height: 14),
            if (showActionsInRow)
              Row(
                children: [
                  Expanded(
                    child: SkeletonBox(
                      width: double.infinity,
                      height: actionHeight,
                      borderRadius: bannerRadius,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: SkeletonBox(
                      width: double.infinity,
                      height: actionHeight,
                      borderRadius: bannerRadius,
                    ),
                  ),
                ],
              )
            else ...[
              SkeletonBox(
                width: double.infinity,
                height: actionHeight,
                borderRadius: bannerRadius,
              ),
              const SizedBox(height: 12),
              SkeletonBox(
                width: double.infinity,
                height: actionHeight,
                borderRadius: bannerRadius,
              ),
            ],
            const SizedBox(height: 28),
            const SkeletonBox(width: 156, height: 18),
            const SizedBox(height: 14),
            Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (var index = 0; index < 4; index++)
                  SkeletonBox(
                    width: sensorWidth,
                    height: sensorHeight,
                    borderRadius: bannerRadius,
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}
