import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/brand_widgets.dart';
import '../../domain/entities/accountability_models.dart';

/// Refined mobile-first hero card for the active accountability partner.
class PartnerStatusCard extends StatelessWidget {
  const PartnerStatusCard({super.key, required this.membership});

  final AccountabilityMembership? membership;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasPartner = membership != null;
    final accent = hasPartner ? AppColors.sage : AppColors.amber;
    final partnerName = membership?.partnerName ?? l10n.partnerNone;
    final isMobile = MediaQuery.sizeOf(context).width < 720;

    final subtitle = hasPartner
        ? l10n.accountabilityActiveGroup(membership?.groupName ?? '')
        : l10n.partnerNoneBody;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Color.alphaBlend(
              accent.withValues(alpha: hasPartner ? 0.06 : 0.04),
              AppColors.surface,
            ),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.banner),
        border: Border.all(color: Colors.white.withValues(alpha: 0.95)),
        boxShadow: AppColors.softShadow,
      ),
      child: Stack(
        children: [
          const Positioned(
            top: -60,
            left: -50,
            child: RadialBlob(color: AppColors.sky, size: 220, alpha: 0.14),
          ),
          Positioned(
            bottom: -70,
            right: -40,
            child: RadialBlob(color: accent, size: 200, alpha: 0.08),
          ),
          Padding(
            padding: EdgeInsets.all(isMobile ? 18 : AppSpacing.xl),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    UserAvatar(
                      key: const ValueKey('accountability-partner-avatar'),
                      name: partnerName,
                      avatarUrl: membership?.partnerAvatarUrl,
                      color: accent,
                      size: isMobile ? 54 : 60,
                      boxShadow: AppColors.cardSoftShadow,
                      border: Border.all(color: Colors.white, width: 2.5),
                    ),
                    if (hasPartner)
                      Positioned(
                        right: -1,
                        bottom: -1,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.sage,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2.2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              partnerName,
                              style: TextStyle(
                                fontSize: isMobile ? 17 : 19,
                                fontWeight: FontWeight.w800,
                                color: AppColors.navyDark,
                                letterSpacing: -0.4,
                              ),
                            ),
                          ),
                          if (hasPartner) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2.5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.sage.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.pill,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 5.5,
                                    height: 5.5,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.sage,
                                    ),
                                  ),
                                  const SizedBox(width: 4.5),
                                  Text(
                                    l10n.statusConnected,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.sage,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: AppColors.mutedForeground,
                          fontSize: isMobile ? 12 : 12.5,
                          height: 1.45,
                        ),
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
