import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/brand_widgets.dart';
import '../../domain/entities/accountability_models.dart';

/// Summarises whether the current account has an active accountability partner.
/// Light glass card with a monogram avatar and soft blob decor.
class PartnerStatusCard extends StatelessWidget {
  const PartnerStatusCard({super.key, required this.membership});

  final AccountabilityMembership? membership;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final hasPartner = membership != null;
    final accent = hasPartner ? AppColors.sage : AppColors.amber;
    final partnerName = membership?.partnerName ?? l10n.partnerNone;
    final subtitle = hasPartner
        ? l10n.accountabilityActiveGroup(membership?.groupName ?? '')
        : l10n.partnerNoneBody;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.banner),
        border: Border.all(color: AppColors.background),
        boxShadow: AppColors.cardSoftShadow,
      ),
      child: Stack(
        children: [
          const Positioned(
            top: -50,
            left: -40,
            child: RadialBlob(color: AppColors.blueAccent, size: 190, alpha: 0.14),
          ),
          const Positioned(
            bottom: -60,
            right: -40,
            child: RadialBlob(color: AppColors.violetAccent, size: 180, alpha: 0.10),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    MonogramAvatar(
                      label: partnerName,
                      color: accent,
                      size: 48,
                      boxShadow: AppColors.cardSoftShadow,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            partnerName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.ink,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            subtitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: AppColors.inkMuted,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (hasPartner) ...[
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.sage.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppColors.sage.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.shield_outlined,
                          size: 12,
                          color: AppColors.sage,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          l10n.partnerPrivacyBadge,
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
          ),
        ],
      ),
    );
  }
}
