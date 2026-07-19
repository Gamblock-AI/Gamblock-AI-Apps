import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/auth/auth_state.dart';
import '../../../../core/messaging/app_messages.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../accountability/domain/entities/accountability_models.dart';
import '../../domain/entities/protection_status.dart';
import 'protection_accountability_section.dart';
import 'protection_actions.dart';
import 'protection_status_card.dart';
import '../../../../core/theme/app_colors.dart';

/// Scrollable Protection content, kept separate from native state orchestration.
class ProtectionScreenBody extends StatelessWidget {
  const ProtectionScreenBody({
    super.key,
    required this.isLoading,
    required this.isActionLoading,
    required this.status,
    required this.error,
    required this.auth,
    required this.accountability,
    required this.requests,
    required this.emergencyRequest,
    required this.onRefresh,
    required this.onOpenSetup,
    required this.onRunSelfTest,
    required this.onRequestApproval,
    required this.onApplyApproval,
    required this.onManagePartner,
    required this.onRequestEmergency,
    required this.onEnterEmergencyKey,
    required this.onLogin,
    required this.onOpenAccountSetup,
  });

  final bool isLoading;
  final bool isActionLoading;
  final ProtectionStatus? status;
  final Object? error;
  final AuthState auth;
  final AccountabilityOverview? accountability;
  final List<ApprovalRequest> requests;
  final EmergencyRequest? emergencyRequest;
  final Future<void> Function() onRefresh;
  final VoidCallback onOpenSetup;
  final VoidCallback onRunSelfTest;
  final VoidCallback onRequestApproval;
  final ValueChanged<ApprovalRequest> onApplyApproval;
  final VoidCallback onManagePartner;
  final VoidCallback onRequestEmergency;
  final VoidCallback onEnterEmergencyKey;
  final VoidCallback onLogin;
  final VoidCallback onOpenAccountSetup;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _DashboardHero(auth: auth, status: status, onOpenSetup: onOpenSetup),
          const SizedBox(height: 16),
          if (auth.isAuthenticated && !auth.emailVerified) ...[
            const _VerificationNotice(),
            const SizedBox(height: 16),
          ],
          if (isLoading && status == null)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(40),
                child: CircularProgressIndicator(),
              ),
            )
          else ...[
            ProtectionStatusCard(status: status),
            const SizedBox(height: 16),
            ProtectionActions(
              isLoading: isActionLoading,
              onOpenSetup: onOpenSetup,
              onRunSelfTest: onRunSelfTest,
            ),
            if (error != null) ...[
              const SizedBox(height: 16),
              EmptyState(
                icon: Icons.cloud_off,
                title: l10n.protectionSyncError,
                hint: AppMessages.friendlyMessage(context, error!),
                actionLabel: l10n.retry,
                onAction: onRefresh,
              ),
            ],
            const SizedBox(height: 24),
            ProtectionAccountabilitySection(
              auth: auth,
              accountability: accountability,
              requests: requests,
              emergencyRequest: emergencyRequest,
              isLoading: isActionLoading,
              onRequestApproval: onRequestApproval,
              onApplyApproval: onApplyApproval,
              onManagePartner: onManagePartner,
              onRequestEmergency: onRequestEmergency,
              onEnterEmergencyKey: onEnterEmergencyKey,
              onLogin: onLogin,
              onOpenSetup: onOpenAccountSetup,
            ),
          ],
        ],
      ),
    );
  }
}

class _DashboardHero extends StatelessWidget {
  const _DashboardHero({
    required this.auth,
    required this.status,
    required this.onOpenSetup,
  });
  final AuthState auth;
  final ProtectionStatus? status;
  final VoidCallback onOpenSetup;

  @override
  Widget build(BuildContext context) {
    final name = auth.displayName?.trim().split(' ').first;
    final active = status?.isActive == true;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.navyGradient,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Halo${name?.isNotEmpty == true ? ', $name' : ''}',
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: AppColors.skyLight),
          ),
          const SizedBox(height: 8),
          Text(
            active
                ? 'Perlindungan perangkat aktif'
                : 'Selesaikan perlindungan perangkat',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Analisis tetap di perangkat. Server hanya menerima hitungan agregat perlindungan.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: .78),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: 220,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.navy,
              ),
              onPressed: onOpenSetup,
              icon: const Icon(Icons.tune_rounded),
              label: const Text('Periksa setup'),
            ),
          ),
        ],
      ),
    );
  }
}

class _VerificationNotice extends ConsumerWidget {
  const _VerificationNotice();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      color: AppColors.azure,
      child: ListTile(
        minTileHeight: 72,
        leading: const Icon(
          Icons.mark_email_unread_outlined,
          color: AppColors.navy,
        ),
        title: const Text('Verifikasi email Anda'),
        subtitle: const Text(
          'Diperlukan untuk fitur pendamping dan pemulihan akun.',
        ),
        trailing: TextButton(
          onPressed: () async {
            try {
              await ref.read(authProvider.notifier).resendEmailVerification();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Email verifikasi dikirim.')),
                );
              }
            } catch (error) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppMessages.friendlyMessage(context, error)),
                  ),
                );
              }
            }
          },
          child: const Text('Kirim ulang'),
        ),
      ),
    );
  }
}
