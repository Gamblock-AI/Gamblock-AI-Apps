import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';

/// Supportive mascot card for encouragement moments (mission completion,
/// analytics appreciation). Mirrors the website's GamiCard: Gami is a
/// guide/supporter voice and never softens consent or critical actions.
class GamiCard extends StatelessWidget {
  const GamiCard({
    super.key,
    this.title,
    required this.message,
    this.asset = 'assets/images/gami-thumbsup.webp',
    this.action,
  });

  final String? title;
  final String message;
  final String asset;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.azure.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.navy.withValues(alpha: 0.15)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -16,
            bottom: -24,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.skyLight.withValues(alpha: 0.45),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.skyLight.withValues(alpha: 0.45),
                  ),
                  child: Image.asset(
                    asset,
                    fit: BoxFit.contain,
                    excludeFromSemantics: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 2),
                          child: Text(
                            title!,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.navy,
                            ),
                          ),
                        ),
                      Text(
                        message,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppColors.navy,
                          height: 1.45,
                        ),
                      ),
                      if (action != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 10),
                          child: action,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
