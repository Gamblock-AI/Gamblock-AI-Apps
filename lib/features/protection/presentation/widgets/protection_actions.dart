import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_busy_indicator.dart';
import '../../../../core/widgets/app_section_header.dart';

/// Two high-priority local protection actions presented as wellness-focus cards.
class ProtectionActions extends StatelessWidget {
  const ProtectionActions({
    super.key,
    required this.isLoading,
    required this.onOpenSetup,
    required this.onRunSelfTest,
  });

  final bool isLoading;
  final VoidCallback onOpenSetup;
  final VoidCallback onRunSelfTest;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(title: l10n.protectionTitle),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final cards = [
              _ActionCard(
                key: const ValueKey('dashboard-platform-setup-card'),
                icon: Icons.tune_rounded,
                accent: AppColors.skyDark,
                title: l10n.protectionSetupAction,
                subtitle: l10n.setupPlatformTitle,
                isLoading: isLoading,
                onTap: onOpenSetup,
              ),
              _ActionCard(
                key: const ValueKey('dashboard-self-test-card'),
                icon: Icons.science_outlined,
                accent: AppColors.amberDark,
                title: l10n.selfTestAction,
                subtitle: l10n.setupSelfTestTitle,
                isLoading: isLoading,
                onTap: onRunSelfTest,
              ),
            ];

            if (constraints.maxWidth < 320) {
              return Column(
                children: [cards.first, const SizedBox(height: 12), cards.last],
              );
            }

            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: cards.first),
                const SizedBox(width: 14),
                Expanded(child: cards.last),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    super.key,
    required this.icon,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.isLoading,
    required this.onTap,
  });

  final IconData icon;
  final Color accent;
  final String title;
  final String subtitle;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final cardHeight = textScale > 1.2 ? 164.0 : 144.0;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(AppRadius.banner),
        child: Container(
          height: cardHeight,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Color.alphaBlend(
              accent.withValues(alpha: 0.08),
              AppColors.surface,
            ),
            borderRadius: BorderRadius.circular(AppRadius.banner),
            border: Border.all(color: Colors.white.withValues(alpha: 0.9)),
            boxShadow: AppColors.cardSoftShadow,
          ),
          child: Stack(
            children: [
              Positioned(
                right: -20,
                bottom: -44,
                child: Container(
                  width: 104,
                  height: 104,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: 0.07),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Icon(icon, size: 19, color: accent),
                      ),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: accent,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: accent.withValues(alpha: 0.25),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: isLoading
                            ? const AppBusyIndicator(
                                size: 13,
                                strokeWidth: 1.8,
                                color: Colors.white,
                                trackColor: Color(0x55FFFFFF),
                              )
                            : const Icon(
                                Icons.arrow_forward_rounded,
                                size: 15,
                                color: Colors.white,
                              ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.2,
                      fontWeight: FontWeight.w800,
                      color: AppColors.navyDark,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.3,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
