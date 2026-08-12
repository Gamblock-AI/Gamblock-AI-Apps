import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import 'avatar_stack.dart';

/// Wireframe "workspace card": white rounded card with a colored left accent
/// bar, a title + more-menu row, a meta row and a footer (icon label + avatar
/// stack). Used in horizontal carousels.
class AccentCarouselCard extends StatelessWidget {
  final String title;
  final Color accentColor;
  final String metaText;
  final IconData metaIcon;
  final String? footerText;
  final IconData? footerIcon;
  final List<String> avatarLabels;
  final Color avatarColor;
  final double width;
  final VoidCallback? onTap;
  final VoidCallback? onMore;

  const AccentCarouselCard({
    super.key,
    required this.title,
    required this.accentColor,
    required this.metaText,
    required this.metaIcon,
    this.footerText,
    this.footerIcon,
    this.avatarLabels = const [],
    this.avatarColor = AppColors.blueAccent,
    this.width = 210,
    this.onTap,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Container(
        width: width,
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: AppColors.cardSoftShadow,
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Center(
                child: Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: accentColor,
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(6),
                    ),
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: AppSpacing.sm),
                      child: SizedBox(
                        width: width * 0.68,
                        child: Text(
                          title,
                          style: t.titleSmall?.copyWith(
                            color: AppColors.ink,
                            fontWeight: FontWeight.w700,
                            height: 1.375,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onMore,
                      icon: const Icon(
                        Icons.more_horiz_rounded,
                        color: AppColors.inkMuted,
                        size: AppIconSize.md,
                      ),
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      splashRadius: 16,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.sm),
                  child: Row(
                    children: [
                      Icon(metaIcon, size: 12, color: AppColors.inkMuted),
                      const SizedBox(width: 6),
                      Text(
                        metaText,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.sm),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      if (footerText != null)
                        Row(
                          children: [
                            if (footerIcon != null)
                              Icon(footerIcon, size: 12, color: AppColors.inkMuted),
                            if (footerIcon != null) const SizedBox(width: 6),
                            Text(
                              footerText!,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.inkMuted,
                              ),
                            ),
                          ],
                        )
                      else
                        const SizedBox.shrink(),
                      AvatarStack(
                        labels: avatarLabels,
                        color: avatarColor,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
