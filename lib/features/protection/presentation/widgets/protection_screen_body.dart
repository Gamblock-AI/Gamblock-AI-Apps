import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/auth/auth_state.dart';
import '../../../../core/messaging/app_messages.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../accountability/domain/entities/accountability_models.dart';
import '../../data/daily_presence_store.dart';
import '../../domain/entities/protection_status.dart';
import '../../../pattern_interrupt/data/providers.dart';
import 'protection_accountability_section.dart';
import '../../../missions/data/providers.dart';
import '../../../missions/presentation/widgets/daily_missions_section.dart';
import '../../../missions/presentation/widgets/mission_level_chip.dart';
import 'breathing_entry_tile.dart';
import 'dashboard_gami.dart';
import 'pause_acknowledgment_card.dart';
import 'protection_actions.dart';
import 'protection_screen_skeleton.dart';
import 'protection_status_card.dart';
import 'protection_weekly_appreciation.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';

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

  /// Gentle staggered entrance for the main dashboard blocks; skipped
  /// entirely (wrapper included) under reduced motion.
  Widget _entrance(BuildContext context, int index, Widget child) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return child
        .animate(delay: (60 * index).ms)
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.05, end: 0, curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          _entrance(
            context,
            0,
            _DashboardHero(
              auth: auth,
              status: status,
              onOpenSetup: onOpenSetup,
              onRefresh: onRefresh,
              refreshing: isLoading,
            ),
          ),
          const SizedBox(height: 16),
          if (auth.isAuthenticated && !auth.phoneVerified) ...[
            const _VerificationNotice(),
            const SizedBox(height: 16),
          ],
          if (isLoading && status == null)
            const ProtectionScreenSkeleton()
          else ...[
            _entrance(context, 1, ProtectionStatusCard(status: status)),
            const SizedBox(height: 16),
            const ProtectionWeeklyAppreciation(),
            _entrance(
              context,
              2,
              ProtectionActions(
                isLoading: isActionLoading,
                onOpenSetup: onOpenSetup,
                onRunSelfTest: onRunSelfTest,
              ),
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
            const PauseAcknowledgmentCard(),
            _entrance(context, 3, const DailyMissionsSection()),
            const SizedBox(height: 16),
            _entrance(context, 4, const BreathingEntryTile()),
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

class _DashboardHero extends ConsumerWidget {
  const _DashboardHero({
    required this.auth,
    required this.status,
    required this.onOpenSetup,
    required this.onRefresh,
    required this.refreshing,
  });

  final AuthState auth;
  final ProtectionStatus? status;
  final VoidCallback onOpenSetup;
  final Future<void> Function() onRefresh;
  final bool refreshing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final missions = ref.watch(missionsProvider);
    final firstOpenToday =
        ref.watch(firstOpenTodayProvider).valueOrNull ?? false;
    final recentPause = ref.watch(recentPauseProvider).valueOrNull;
    final gami = resolveDashboardGami(
      missionsAllDone: missions.mission?.allResolved ?? false,
      pauseTaken: recentPause != null,
      firstOpenToday: firstOpenToday,
    );
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
      decoration: BoxDecoration(
        gradient: AppColors.navyGradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -6,
            bottom: -10,
            child: Opacity(
              opacity: 0.9,
              child: Image.asset(
                gami.asset,
                height: 88,
                cacheWidth: 264,
                excludeFromSemantics: true,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/images/gami.webp',
                  height: 88,
                  cacheWidth: 264,
                  excludeFromSemantics: true,
                ),
              ),
            ),
          ),
          _heroContent(context, gami),
        ],
      ),
    );
  }

  Widget _heroContent(BuildContext context, DashboardGamiPresentation gami) {
    final l10n = AppLocalizations.of(context)!;
    final name = auth.displayName?.trim().split(' ').first;
    final active = status?.isActive == true;
    final greeting = name?.isNotEmpty == true
        ? l10n.dashboardHello(name!)
        : l10n.dashboardHelloGuest;
    final l10nRefresh = l10n.refresh;
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  greeting,
                  style: const TextStyle(
                    color: AppColors.skyLight,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              IconButton(
                tooltip: l10nRefresh,
                onPressed: refreshing ? null : () => onRefresh(),
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(
                  minWidth: 36,
                  minHeight: 36,
                ),
                iconSize: 20,
                color: Colors.white.withValues(alpha: 0.85),
                disabledColor: Colors.white.withValues(alpha: 0.35),
                icon: const Icon(Icons.refresh_rounded),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            active
                ? l10n.protectionActiveTitle
                : l10n.protectionInactiveTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.protectionOnDevicePrivacyDesc,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13,
              height: 1.45,
            ),
          ),
          if (gami.lineBuilder != null) ...[
            const SizedBox(height: 8),
            Text(
              gami.lineBuilder!(l10n),
              style: const TextStyle(
                color: AppColors.skyLight,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 14),
          const MissionLevelChip(),
          const SizedBox(height: 14),
          SizedBox(
            height: 38,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.navy,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: onOpenSetup,
              icon: const Icon(Icons.tune_rounded, size: 16),
              label: Text(
                l10n.checkSetupAction,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
            ),
          ),
        ],
    );
  }
}

class _VerificationNotice extends ConsumerStatefulWidget {
  const _VerificationNotice();

  @override
  ConsumerState<_VerificationNotice> createState() => _VerificationNoticeState();
}

class _VerificationNoticeState extends ConsumerState<_VerificationNotice> {
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  String? _previewCode;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      color: AppColors.azure,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(Icons.phone_rounded, color: AppColors.navy),
                const SizedBox(width: 10),
                Expanded(child: Text(l10n.verifyEmailTitle)),
              ],
            ),
            const SizedBox(height: 8),
            Text(l10n.verifyEmailBody),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: '+6281234567890',
                labelText: l10n.authWhatsapp,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n.codeVerificationLabel,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () async {
                    try {
                      _previewCode = await ref
                          .read(authProvider.notifier)
                          .startPhoneVerification(_phoneController.text);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.verifyEmailSent)),
                        );
                        setState(() {});
                      }
                    } catch (error) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              AppMessages.friendlyMessage(context, error),
                            ),
                          ),
                        );
                      }
                    }
                  },
                  child: Text(l10n.resendEmail),
                ),
              ],
            ),
            if (_previewCode != null) Text('Demo code: $_previewCode'),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () async {
                try {
                  await ref
                      .read(authProvider.notifier)
                      .confirmPhoneVerification(_codeController.text);
                  if (context.mounted) setState(() {});
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
              child: Text(l10n.verifyCode),
            ),
          ],
        ),
      ),
    );
  }
}
