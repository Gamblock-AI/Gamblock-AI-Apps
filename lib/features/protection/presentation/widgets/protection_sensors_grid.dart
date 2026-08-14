import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_section_header.dart';
import '../../../../core/widgets/gami_image.dart';
import '../../domain/entities/protection_status.dart';

/// Responsive wellness-card grid for the four core local protection signals.
class ProtectionSensorsGrid extends StatelessWidget {
  const ProtectionSensorsGrid({super.key, required this.status});

  final ProtectionStatus? status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final serviceOk = status?.serviceRunning == true;
    final sensorStatus = status?.sensorStatus.toLowerCase() ?? '';
    final sensorOk =
        sensorStatus == 'connected' ||
        sensorStatus == 'running' ||
        sensorStatus == 'active';
    final sensorWarn = sensorStatus == 'degraded' || sensorStatus == 'unknown';
    final permissionOk = status?.permissionStatus.toLowerCase() == 'granted';

    final cards = [
      _SensorGridCard(
        key: const ValueKey('protection-sensor-service'),
        tag: _platformLabel(l10n, status?.platform),
        tagTone: AppColors.navyLight,
        title: l10n.protectionServiceLabel,
        subtitle: serviceOk
            ? l10n.sensorServiceActive
            : l10n.sensorServiceAction,
        asset: 'assets/images/gami-sensor-service.webp',
        isHealthy: serviceOk,
      ),
      _SensorGridCard(
        key: const ValueKey('protection-sensor-browser'),
        tag: l10n.protectionSensorSubDomRelay,
        tagTone: AppColors.skyDark,
        title: l10n.protectionSensorLabel,
        subtitle: sensorOk
            ? l10n.sensorBrowserActive
            : sensorWarn
            ? l10n.sensorBrowserDegraded
            : l10n.sensorBrowserAction,
        asset: 'assets/images/gami-sensor-browser.webp',
        isHealthy: sensorOk,
        isWarning: sensorWarn,
      ),
      _SensorGridCard(
        key: const ValueKey('protection-sensor-permission'),
        tag: l10n.protectionSensorSubAccessibility,
        tagTone: AppColors.amberDark,
        title: l10n.protectionPermissionLabel,
        subtitle: permissionOk
            ? l10n.sensorPermissionActive
            : l10n.sensorPermissionAction,
        asset: 'assets/images/gami-sensor-permission.webp',
        isHealthy: permissionOk,
      ),
      _SensorGridCard(
        key: const ValueKey('protection-sensor-model'),
        tag: l10n.protectionPlatformLocal,
        tagTone: AppColors.sage,
        title: l10n.protectionArtifactLabel,
        subtitle: l10n.sensorModelActive,
        asset: 'assets/images/gami-sensor-model.webp',
        isHealthy: true,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppSectionHeader(title: l10n.protectionSensorsTitle),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final columnCount = constraints.maxWidth >= 900 ? 4 : 2;
            const gap = 10.0;
            final cardWidth =
                (constraints.maxWidth - (gap * (columnCount - 1))) /
                columnCount;
            return Wrap(
              spacing: gap,
              runSpacing: gap,
              children: [
                for (final card in cards)
                  SizedBox(width: cardWidth, child: card),
              ],
            );
          },
        ),
      ],
    );
  }

  String _platformLabel(AppLocalizations l10n, String? platform) {
    switch (platform?.toLowerCase()) {
      case 'android':
        return l10n.protectionPlatformAndroid;
      case 'windows':
        return l10n.protectionPlatformWindows;
      case 'linux':
        return l10n.protectionPlatformLinux;
      case 'macos':
      case 'mac':
        return l10n.protectionPlatformMacos;
      default:
        return l10n.protectionPlatformLocal;
    }
  }
}

/// A compact status card with a dedicated Gami pose for its local signal.
class _SensorGridCard extends StatelessWidget {
  const _SensorGridCard({
    super.key,
    required this.tag,
    required this.tagTone,
    required this.title,
    required this.subtitle,
    required this.asset,
    required this.isHealthy,
    this.isWarning = false,
  });

  final String tag;
  final Color tagTone;
  final String title;
  final String subtitle;
  final String asset;
  final bool isHealthy;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    final statusColor = isHealthy
        ? AppColors.sage
        : (isWarning ? AppColors.amber : AppColors.crimson);
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final cardHeight = textScale > 1.2 ? 186.0 : 166.0;
    return Semantics(
      label: '$title, $subtitle',
      container: true,
      child: Container(
        height: cardHeight,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Color.alphaBlend(tagTone.withValues(alpha: 0.035), Colors.white),
            ],
          ),
          borderRadius: BorderRadius.circular(AppRadius.banner),
          border: Border.all(color: Colors.white.withValues(alpha: 0.95)),
          boxShadow: AppColors.cardSoftShadow,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              right: -30,
              bottom: -50,
              child: Container(
                width: 132,
                height: 132,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tagTone.withValues(alpha: 0.07),
                ),
              ),
            ),
            Positioned(
              right: -1,
              bottom: -3,
              child: GamiImage(
                asset: asset,
                width: 96,
                height: 96,
                cacheWidth: 320,
                alignment: Alignment.bottomRight,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 10, 11),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              color: tagTone.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(AppRadius.xs),
                              border: Border.all(
                                color: tagTone.withValues(alpha: 0.16),
                              ),
                            ),
                            child: Text(
                              tag,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: tagTone,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.1,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: statusColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: statusColor.withValues(alpha: 0.45),
                              blurRadius: 7,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.navyDark,
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      height: 1.15,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 110),
                    child: Text(
                      subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isHealthy
                            ? AppColors.mutedForeground
                            : (isWarning
                                ? AppColors.amberDark
                                : AppColors.crimson),
                        fontSize: 10.5,
                        fontWeight: isHealthy
                            ? FontWeight.w500
                            : FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
