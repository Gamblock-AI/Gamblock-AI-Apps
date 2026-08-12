import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/glass_card.dart';
import '../../domain/entities/protection_status.dart';

/// Displays the native protection state in a compact, structured card.
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
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    active ? Icons.shield_rounded : Icons.shield_outlined,
                    color: color,
                    size: 20,
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
                              color: AppColors.navy,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _formatDegradedReason(
                              context,
                              status?.degradedReasonCode,
                            ) ??
                            l10n.protectionStatusLocal,
                        style: const TextStyle(
                          color: AppColors.mutedForeground,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        active
                            ? l10n.statusChipOk
                            : degraded || paused
                                ? l10n.statusChipWarn
                                : l10n.statusChipOff,
                        style: TextStyle(
                          color: color,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Model & Ruleset compact footer bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.6),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.memory_rounded,
                    size: 16,
                    color: AppColors.mutedForeground,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${status?.modelVersion ?? l10n.protectionArtifactUnavailable} · '
                      '${status?.rulesetVersion ?? l10n.protectionArtifactUnavailable}',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        color: AppColors.navy.withValues(alpha: 0.75),
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
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
    default:
      return code
          .split('_')
          .where((w) => w.isNotEmpty)
          .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
          .join(' ');
  }
}
