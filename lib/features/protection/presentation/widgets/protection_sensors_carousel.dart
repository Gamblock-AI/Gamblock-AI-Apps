import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/accent_carousel_card.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../domain/entities/protection_status.dart';

/// Wireframe-style "Devices & Sensors" carousel: colored accent cards for the
/// local service, browser sensor and access permission state.
class ProtectionSensorsCarousel extends StatelessWidget {
  const ProtectionSensorsCarousel({super.key, required this.status});

  final ProtectionStatus? status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final serviceOk = status?.serviceRunning == true;
    final permissionOk = status?.permissionStatus.toLowerCase() == 'granted';

    final cards = [
      AccentCarouselCard(
        title: l10n.protectionServiceLabel,
        accentColor: AppColors.sage,
        metaIcon: Icons.memory_rounded,
        metaText: serviceOk ? l10n.statusConnected : l10n.statusDisconnected,
        footerText: status?.platform ?? '-',
        footerIcon: Icons.smartphone_rounded,
      ),
      AccentCarouselCard(
        title: l10n.protectionSensorLabel,
        accentColor: AppColors.blueAccent,
        metaIcon: Icons.public_rounded,
        metaText: _formatSensor(context, status?.sensorStatus),
        footerText: '${status?.modelVersion ?? '-'} · ${status?.rulesetVersion ?? '-'}',
        footerIcon: Icons.science_outlined,
      ),
      AccentCarouselCard(
        title: l10n.protectionPermissionLabel,
        accentColor: AppColors.violetAccent,
        metaIcon: Icons.verified_user_outlined,
        metaText: permissionOk ? l10n.statusGranted : l10n.statusRevoked,
        footerText: l10n.protectionStatusLocal,
        footerIcon: Icons.shield_outlined,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(title: l10n.protectionSensorsTitle),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.lg),
                cards[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

String _formatSensor(BuildContext context, String? value) {
  final l10n = AppLocalizations.of(context)!;
  if (value == null || value.isEmpty) return l10n.statusDisconnected;
  switch (value.toLowerCase()) {
    case 'connected':
    case 'running':
    case 'active':
      return l10n.statusConnected;
    case 'disconnected':
    case 'stopped':
    case 'inactive':
      return l10n.statusDisconnected;
    case 'disabled':
    case 'accessibility_disabled':
      return l10n.statusDisabled;
    case 'unknown':
      return l10n.statusUnknown;
    default:
      return value;
  }
}
