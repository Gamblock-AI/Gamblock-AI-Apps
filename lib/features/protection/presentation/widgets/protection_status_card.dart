import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/theme/app_colors.dart';
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

    final sensorLower = status?.sensorStatus.toLowerCase();
    final permissionLower = status?.permissionStatus.toLowerCase();

    return Semantics(
      liveRegion: true,
      label: title,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border.withValues(alpha: 0.8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
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
                            ? 'OK'
                            : degraded || paused
                                ? 'WARN'
                                : 'OFF',
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

            // Compact 3-Column Status Indicators
            Row(
              children: [
                Expanded(
                  child: _metricBox(
                    context,
                    label: l10n.protectionServiceLabel,
                    value: status?.serviceRunning == true
                        ? l10n.statusConnected
                        : l10n.statusDisconnected,
                    isGood: status?.serviceRunning == true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _metricBox(
                    context,
                    label: l10n.protectionSensorLabel,
                    value: _formatStatusValue(context, status?.sensorStatus),
                    isGood: sensorLower == 'connected' || sensorLower == 'running',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _metricBox(
                    context,
                    label: l10n.protectionPermissionLabel,
                    value: _formatStatusValue(context, status?.permissionStatus),
                    isGood: permissionLower == 'granted',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Model & Ruleset compact footer bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.6),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.memory_rounded,
                    size: 14,
                    color: AppColors.mutedForeground,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${status?.modelVersion ?? 'gamblock-lr-bfafb725511a'} · '
                      '${status?.rulesetVersion ?? 'gambling-keywords-b4f2932a7647'}',
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

  Widget _metricBox(
    BuildContext context, {
    required String label,
    required String value,
    required bool isGood,
  }) {
    final statusColor = isGood ? AppColors.sage : AppColors.crimson;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.mutedForeground,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String? _formatDegradedReason(BuildContext context, String? code) {
  if (code == null || code.isEmpty) return null;
  final isId = Localizations.localeOf(context).languageCode == 'id';
  switch (code.toLowerCase()) {
    case 'accessibility_disabled':
      return isId ? 'Aksesibilitas dinonaktifkan' : 'Accessibility disabled';
    case 'accessibility_not_granted':
      return isId
          ? 'Izin aksesibilitas belum diberikan'
          : 'Accessibility permission not granted';
    case 'service_stopped':
      return isId ? 'Layanan proteksi terhenti' : 'Protection service stopped';
    case 'permission_revoked':
      return isId ? 'Izin sistem dicabut' : 'System permission revoked';
    case 'sensor_disconnected':
      return isId ? 'Sensor terputus' : 'Sensor disconnected';
    default:
      return code
          .split('_')
          .where((w) => w.isNotEmpty)
          .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
          .join(' ');
  }
}

String _formatStatusValue(BuildContext context, String? value) {
  final l10n = AppLocalizations.of(context)!;
  final isId = Localizations.localeOf(context).languageCode == 'id';
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
    case 'granted':
      return isId ? 'Diberikan' : 'Granted';
    case 'revoked':
    case 'permission_revoked':
      return isId ? 'Dicabut' : 'Revoked';
    case 'disabled':
    case 'accessibility_disabled':
      return isId ? 'Nonaktif' : 'Disabled';
    case 'unknown':
      return isId ? 'Tidak diketahui' : 'Unknown';
    default:
      return value
          .split('_')
          .where((w) => w.isNotEmpty)
          .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
          .join(' ');
  }
}
