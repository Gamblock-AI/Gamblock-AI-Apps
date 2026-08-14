import 'package:flutter/material.dart';

import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/skeleton_box.dart';

/// Loading placeholder mirroring the partner hero card and request rows.
class AccountabilitySkeleton extends StatelessWidget {
  const AccountabilitySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final rowRadius = BorderRadius.circular(AppRadius.md);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SkeletonBox(
          width: double.infinity,
          height: 126,
          borderRadius: BorderRadius.circular(AppRadius.banner),
        ),
        const SizedBox(height: 12),
        SkeletonBox(
          width: double.infinity,
          height: 132,
          borderRadius: BorderRadius.circular(AppRadius.banner),
        ),
        const SizedBox(height: 20),
        for (var i = 0; i < 3; i++) ...[
          SkeletonBox(
            width: double.infinity,
            height: 68,
            borderRadius: rowRadius,
          ),
          if (i < 2) const SizedBox(height: 10),
        ],
      ],
    );
  }
}
