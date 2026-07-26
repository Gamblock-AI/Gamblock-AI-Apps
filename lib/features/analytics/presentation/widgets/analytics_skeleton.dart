import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/skeleton_box.dart';

/// Loading placeholder mirroring the analytics totals grid and trend chart.
class AnalyticsSkeleton extends StatelessWidget {
  const AnalyticsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final tileRadius = BorderRadius.circular(AppRadius.sm);
    Widget tile() => Expanded(
          child: SkeletonBox(
            width: double.infinity,
            height: 56,
            borderRadius: tileRadius,
          ),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [tile(), const SizedBox(width: 8), tile()]),
        const SizedBox(height: 8),
        Row(children: [tile(), const SizedBox(width: 8), tile()]),
        const SizedBox(height: 14),
        SkeletonBox(
          width: double.infinity,
          height: 240,
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ],
    );
  }
}
