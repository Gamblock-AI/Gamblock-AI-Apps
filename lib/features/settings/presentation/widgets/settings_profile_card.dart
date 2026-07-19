import 'package:flutter/material.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/auth/auth_state.dart';
import '../../../../core/theme/app_colors.dart';

/// Identifies the authenticated user at the top of the Settings screen.
class SettingsProfileCard extends StatelessWidget {
  const SettingsProfileCard({super.key, required this.auth});

  final AuthState auth;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final displayName = auth.displayName?.trim();
    final initial = displayName?.isNotEmpty == true ? displayName![0] : '?';
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: AppColors.navy.withValues(alpha: 0.1),
              child: Text(
                initial.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.navy,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    auth.displayName ?? l10n.settingsUserFallback,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    auth.email ?? '',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mutedForeground,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      _CapabilityChip(
                        label: auth.emailVerified
                            ? 'Email terverifikasi'
                            : 'Email belum terverifikasi',
                        active: auth.emailVerified,
                      ),
                      _CapabilityChip(
                        label: auth.googleLinked
                            ? 'Google tertaut'
                            : 'Google belum tertaut',
                        active: auth.googleLinked,
                      ),
                    ],
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

class _CapabilityChip extends StatelessWidget {
  const _CapabilityChip({required this.label, required this.active});
  final String label;
  final bool active;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
    decoration: BoxDecoration(
      color: active ? const Color(0xFFD9F0E5) : AppColors.muted,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      label,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: active ? const Color(0xFF1B4332) : AppColors.mutedForeground,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}
