import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import 'avatar_stack.dart';

/// Modern dashboard carousel card: rounded surface with an accent icon badge,
/// live status pill, clear typography, and a structured metadata footer.
class AccentCarouselCard extends StatelessWidget {
  final String title;
  final String? subtitle;
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
    this.subtitle,
    required this.accentColor,
    required this.metaText,
    required this.metaIcon,
    this.footerText,
    this.footerIcon,
    this.avatarLabels = const [],
    this.avatarColor = AppColors.blueAccent,
    this.width = 216,
    this.onTap,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Container(
          width: width,
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border.withValues(alpha: 0.85)),
            boxShadow: AppColors.cardSoftShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Row: Accent Icon + Status Pill / More Action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          accentColor.withValues(alpha: 0.16),
                          accentColor.withValues(alpha: 0.05),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: accentColor.withValues(alpha: 0.25),
                        width: 1.2,
                      ),
                    ),
                    child: Icon(
                      metaIcon,
                      color: accentColor,
                      size: 19,
                    ),
                  ),
                  if (onMore != null)
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
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3.5,
                      ),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        border: Border.all(
                          color: accentColor.withValues(alpha: 0.25),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: accentColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: accentColor.withValues(alpha: 0.4),
                                  blurRadius: 3,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 4.5),
                          Text(
                            metaText,
                            style: TextStyle(
                              color: accentColor,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Title and Subtitle
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.titleSmall?.copyWith(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w700,
                  fontSize: 14.5,
                  height: 1.25,
                ),
              ),
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.mutedForeground,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ] else if (onMore != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(metaIcon, size: 12, color: AppColors.inkMuted),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        metaText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),

              // Footer Metadata Row
              if (footerText != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.7),
                    ),
                  ),
                  child: Row(
                    children: [
                      if (footerIcon != null) ...[
                        Icon(
                          footerIcon,
                          size: 13,
                          color: AppColors.mutedForeground,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Expanded(
                        child: Text(
                          footerText!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w500,
                            color: AppColors.mutedForeground,
                          ),
                        ),
                      ),
                      if (avatarLabels.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        AvatarStack(
                          labels: avatarLabels,
                          color: avatarColor,
                          size: 18,
                        ),
                      ],
                    ],
                  ),
                )
              else if (avatarLabels.isNotEmpty)
                Align(
                  alignment: Alignment.centerRight,
                  child: AvatarStack(
                    labels: avatarLabels,
                    color: avatarColor,
                    size: 20,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
