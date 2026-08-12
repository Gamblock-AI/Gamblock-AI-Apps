import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/auth/auth_state.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/brand_widgets.dart';

/// Identifies the authenticated user at the top of the Settings screen.
/// Light glass card with a monogram avatar and soft blob decor.
class SettingsProfileCard extends StatelessWidget {
  const SettingsProfileCard({super.key, required this.auth});

  final AuthState auth;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displayName = auth.displayName?.trim();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
            right: -40,
            top: -40,
            child: RadialBlob(color: AppColors.blueAccent, size: 170, alpha: 0.14),
          ),
          const Positioned(
            bottom: -50,
            left: -40,
            child: RadialBlob(color: AppColors.violetAccent, size: 160, alpha: 0.10),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Stack(
                  children: [
                    MonogramAvatar(
                      label: displayName?.isNotEmpty == true ? displayName! : 'G',
                      color: AppColors.navy,
                      size: 52,
                      boxShadow: AppColors.cardSoftShadow,
                    ),
                    if (auth.phoneVerified)
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: const Icon(
                            Icons.verified_rounded,
                            size: 16,
                            color: AppColors.sage,
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
                      Text(
                        auth.displayName ?? l10n.settingsUserFallback,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink,
                          letterSpacing: -0.3,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        auth.email ?? '',
                        style: const TextStyle(
                          color: AppColors.inkMuted,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          _CapabilityChip(
                            icon: auth.phoneVerified
                                ? Icons.check_circle_rounded
                                : Icons.pending_rounded,
                            label: auth.phoneVerified
                                ? l10n.settingsWhatsappVerified
                                : l10n.settingsWhatsappUnverified,
                            active: auth.phoneVerified,
                          ),
                        ],
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

class _CapabilityChip extends StatelessWidget {
  const _CapabilityChip({
    required this.icon,
    required this.label,
    required this.active,
  });

  final IconData icon;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.sage : AppColors.inkMuted;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
