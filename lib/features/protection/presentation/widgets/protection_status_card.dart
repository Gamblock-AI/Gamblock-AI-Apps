import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/protection_status.dart';

/// Displays the native protection state without making it actionable.
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
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.shield_outlined, color: color),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        Text(
                          status?.degradedReasonCode ??
                              l10n.protectionStatusLocal,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.mutedForeground),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _statusLine(
                context,
                l10n.protectionServiceLabel,
                status?.serviceRunning == true
                    ? l10n.statusConnected
                    : l10n.statusDisconnected,
              ),
              _statusLine(
                context,
                l10n.protectionSensorLabel,
                status?.sensorStatus ?? 'disconnected',
              ),
              _statusLine(
                context,
                l10n.protectionPermissionLabel,
                status?.permissionStatus ?? 'unknown',
              ),
              _statusLine(
                context,
                l10n.protectionArtifactLabel,
                '${status?.modelVersion ?? 'dummy-lr-v1'} · '
                '${status?.rulesetVersion ?? 'dummy-rules-v1'}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _statusLine(BuildContext context, String label, String value) {
  return Padding(
    padding: const EdgeInsets.only(top: 8),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.mutedForeground),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}
