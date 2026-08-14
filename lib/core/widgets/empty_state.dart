import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import 'gami_image.dart';

enum AppStateTone { neutral, protected, success, warning, error }

/// Branded state card for empty, access-gated, and recoverable error surfaces.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.hint,
    this.actionLabel,
    this.onAction,
    this.radius = AppRadius.md,
    this.tone = AppStateTone.neutral,
    this.mascotAsset = 'assets/images/gami-peek.webp',
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String? hint;
  final String? actionLabel;
  final VoidCallback? onAction;
  final double radius;
  final AppStateTone tone;
  final String? mascotAsset;
  final bool compact;

  Color get _accent {
    switch (tone) {
      case AppStateTone.neutral:
        return AppColors.navyLight;
      case AppStateTone.protected:
        return AppColors.skyDark;
      case AppStateTone.success:
        return AppColors.sage;
      case AppStateTone.warning:
        return AppColors.amberDark;
      case AppStateTone.error:
        return AppColors.crimson;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final accent = _accent;
    final mascotSize = compact ? 88.0 : 108.0;
    return Semantics(
      container: true,
      liveRegion: tone == AppStateTone.error,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Container(
            width: double.infinity,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.alphaBlend(
                    accent.withValues(alpha: 0.11),
                    Colors.white,
                  ),
                  Colors.white.withValues(alpha: 0.92),
                ],
              ),
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: Colors.white.withValues(alpha: 0.92)),
              boxShadow: AppColors.softShadow,
            ),
            child: Stack(
              children: [
                Positioned(
                  top: compact ? -32 : -40,
                  right: compact ? -28 : -34,
                  child: Container(
                    width: compact ? 128 : 166,
                    height: compact ? 128 : 166,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.10),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                if (mascotAsset != null)
                  Positioned(
                    right: compact ? 8 : 10,
                    top: compact ? 6 : 10,
                    child: GamiImage(
                      asset: mascotAsset!,
                      width: mascotSize,
                      height: mascotSize,
                      cacheWidth: 280,
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    compact ? 16 : 22,
                    compact ? 16 : 22,
                    mascotAsset == null
                        ? (compact ? 16 : 22)
                        : (compact ? 108 : 124),
                    compact ? 16 : 22,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (compact)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(11),
                                border: Border.all(
                                  color: accent.withValues(alpha: 0.12),
                                ),
                              ),
                              child: Icon(icon, size: 19, color: accent),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text(
                                  title,
                                  style: textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.navyDark,
                                    height: 1.25,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      else ...[
                        Container(
                          padding: const EdgeInsets.all(9),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                            border: Border.all(
                              color: accent.withValues(alpha: 0.12),
                            ),
                          ),
                          child: Icon(icon, size: 24, color: accent),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          title,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.navyDark,
                            height: 1.25,
                          ),
                        ),
                      ],
                      if (hint != null) ...[
                        SizedBox(height: compact ? 8 : 5),
                        Text(
                          hint!,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppColors.mutedForeground,
                            height: 1.45,
                          ),
                        ),
                      ],
                      if (actionLabel != null && onAction != null) ...[
                        SizedBox(height: compact ? 12 : 16),
                        FilledButton.tonalIcon(
                          style: FilledButton.styleFrom(
                            minimumSize: Size(0, compact ? 40 : 44),
                            foregroundColor: accent,
                            backgroundColor: accent.withValues(alpha: 0.12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                AppRadius.pill,
                              ),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: compact ? 14 : 18,
                            ),
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          onPressed: onAction,
                          icon: const Icon(
                            Icons.arrow_forward_rounded,
                            size: 18,
                          ),
                          label: Text(actionLabel!),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
