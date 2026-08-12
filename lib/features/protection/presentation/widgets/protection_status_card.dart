import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/entities/protection_status.dart';

/// Displays the native protection state in a compact, premium card.
class ProtectionStatusCard extends StatelessWidget {
  const ProtectionStatusCard({super.key, required this.status});

  final ProtectionStatus? status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final active = status?.isActive == true;
    final paused = status?.isPaused == true;
    final degraded = status?.isDegraded == true;

    final color = active
        ? AppColors.sage
        : paused || degraded
            ? AppColors.amber
            : AppColors.crimson;

    final title = active
        ? l10n.protectionStatusActive
        : paused
            ? l10n.protectionStatusPaused
            : degraded
                ? l10n.protectionStatusDegraded
                : l10n.protectionStatusInactive;

    final subtitle = _formatDegradedReason(
          context,
          status?.degradedReasonCode,
        ) ??
        (active
            ? l10n.protectionStatusLocal
            : l10n.protectionInactiveTitle);

    final chipText = active
        ? l10n.statusChipOk
        : degraded || paused
            ? l10n.statusChipWarn
            : l10n.statusChipOff;

    final iconData = active
        ? Icons.shield_rounded
        : paused
            ? Icons.pause_circle_outline_rounded
            : degraded
                ? Icons.gpp_maybe_rounded
                : Icons.shield_outlined;

    return Semantics(
      liveRegion: true,
      label: title,
      child: SurfaceCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header Row
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withValues(alpha: 0.16),
                        color.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(
                      color: color.withValues(alpha: 0.25),
                      width: 1.2,
                    ),
                  ),
                  child: Icon(
                    iconData,
                    color: color,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                              letterSpacing: -0.2,
                              fontSize: 15,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.mutedForeground,
                          fontSize: 12,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4.5),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(
                      color: color.withValues(alpha: 0.28),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6.5,
                        height: 6.5,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: color.withValues(alpha: 0.45),
                              blurRadius: 3,
                              spreadRadius: 0.5,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        chipText,
                        style: TextStyle(
                          color: color,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 13),

            // Privacy-first on-device assurance footer bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8.5),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.8),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.navy.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Icon(
                      Icons.psychology_outlined,
                      size: 14,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      active
                          ? l10n.protectionStatusLocalActive
                          : l10n.protectionStatusLocalInactive,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.navy,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.sage.withValues(alpha: 0.09),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.sage.withValues(alpha: 0.22),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.lock_rounded,
                          size: 9.5,
                          color: AppColors.sage,
                        ),
                        const SizedBox(width: 3.5),
                        Text(
                          l10n.protectionStatusPrivateChip,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.4,
                            color: AppColors.sage,
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
      ),
    );
  }
}

String? _formatDegradedReason(BuildContext context, String? code) {
  if (code == null || code.isEmpty) return null;
  final l10n = AppLocalizations.of(context)!;
  switch (code.toLowerCase()) {
    case 'accessibility_disabled':
      return l10n.degradedAccessibilityDisabled;
    case 'accessibility_not_granted':
      return l10n.degradedAccessibilityNotGranted;
    case 'service_stopped':
      return l10n.degradedServiceStopped;
    case 'permission_revoked':
      return l10n.degradedPermissionRevoked;
    case 'sensor_disconnected':
      return l10n.degradedSensorDisconnected;
    case 'native_bridge_unavailable':
      return l10n.selfTestNativeUnavailable;
    default:
      return code
          .split('_')
          .where((w) => w.isNotEmpty)
          .map((w) => '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}')
          .join(' ');
  }
}
