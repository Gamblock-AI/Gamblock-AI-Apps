import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/accent_carousel_card.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../domain/entities/protection_status.dart';

/// "Devices & Sensors" carousel: status-aware cards for the
/// local service, passive browser sensor, and system permission state.
class ProtectionSensorsCarousel extends StatelessWidget {
  const ProtectionSensorsCarousel({super.key, required this.status});

  final ProtectionStatus? status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final serviceOk = status?.serviceRunning == true;
    final sensorStatus = status?.sensorStatus.toLowerCase() ?? '';
    final sensorOk = sensorStatus == 'connected' ||
        sensorStatus == 'running' ||
        sensorStatus == 'active';
    final sensorWarn = sensorStatus == 'degraded' || sensorStatus == 'unknown';
    final permissionOk = status?.permissionStatus.toLowerCase() == 'granted';

    final serviceColor = serviceOk ? AppColors.sage : AppColors.crimson;
    final sensorColor = sensorOk
        ? AppColors.sage
        : sensorWarn
            ? AppColors.amber
            : AppColors.crimson;
    final permissionColor = permissionOk ? AppColors.sage : AppColors.crimson;

    final cards = [
      AccentCarouselCard(
        title: l10n.protectionServiceLabel,
        subtitle: l10n.protectionSensorSubLocalService,
        accentColor: serviceColor,
        metaIcon: Icons.dns_rounded,
        metaText: serviceOk ? l10n.statusConnected : l10n.statusDisconnected,
        footerText: _formatPlatform(l10n, status?.platform),
        footerIcon: _platformIcon(status?.platform),
      ),
      AccentCarouselCard(
        title: l10n.protectionSensorLabel,
        subtitle: l10n.protectionSensorSubDomRelay,
        accentColor: sensorColor,
        metaIcon: Icons.sensors_rounded,
        metaText: sensorOk ? l10n.statusConnected : l10n.statusDisconnected,
        footerText: l10n.protectionSensorFooterLoopback,
        footerIcon: Icons.extension_rounded,
      ),
      AccentCarouselCard(
        title: l10n.protectionPermissionLabel,
        subtitle: l10n.protectionSensorSubAccessibility,
        accentColor: permissionColor,
        metaIcon: Icons.verified_user_rounded,
        metaText: permissionOk ? l10n.statusConnected : l10n.statusDisconnected,
        footerText: l10n.protectionSensorFooterPrivacy,
        footerIcon: Icons.lock_outline_rounded,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(title: l10n.protectionSensorsTitle),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(width: AppSpacing.md),
                cards[i],
              ],
            ],
          ),
        ),
      ],
    );
  }
}

String _formatPlatform(AppLocalizations l10n, String? platform) {
  if (platform == null || platform.isEmpty || platform == 'unsupported') {
    return l10n.protectionPlatformLocal;
  }
  switch (platform.toLowerCase()) {
    case 'android':
      return l10n.protectionPlatformAndroid;
    case 'windows':
      return l10n.protectionPlatformWindows;
    case 'linux':
      return l10n.protectionPlatformLinux;
    case 'macos':
      return l10n.protectionPlatformMacos;
    default:
      return platform;
  }
}

IconData _platformIcon(String? platform) {
  if (platform == null) return Icons.devices_rounded;
  switch (platform.toLowerCase()) {
    case 'android':
      return Icons.phone_android_rounded;
    case 'windows':
      return Icons.desktop_windows_rounded;
    case 'linux':
    case 'macos':
      return Icons.laptop_rounded;
    default:
      return Icons.devices_rounded;
  }
}
