import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/auth/auth_state.dart';
import '../../../../core/messaging/app_messages.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/brand_widgets.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../accountability/domain/entities/accountability_models.dart';
import '../../data/daily_presence_store.dart';
import '../../domain/entities/protection_status.dart';
import 'dashboard_gami.dart';
import 'protection_accountability_section.dart';
import 'protection_actions.dart';
import 'protection_screen_skeleton.dart';
import 'protection_sensors_carousel.dart';
import 'protection_status_card.dart';
import 'protection_weekly_appreciation.dart';

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
          _DashboardProfileHeader(
            auth: auth,
            status: status,
            onRefresh: onRefresh,
            refreshing: isLoading,
          ),
          const SizedBox(height: 16),
          if (auth.isAuthenticated && !auth.phoneVerified) ...[
            const _VerificationNotice(),
            const SizedBox(height: 16),
          ],
          const SizedBox(height: 4),
          if (isLoading && status == null)
            const ProtectionScreenSkeleton()
          else ...[
            _entrance(
              context,
              0,
              _StatusBanner(
                auth: auth,
                status: status,
                onOpenSetup: onOpenSetup,
              ),
            ),
            const SizedBox(height: 16),
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
            const SizedBox(height: 24),
            _entrance(context, 3, ProtectionSensorsCarousel(status: status)),
            const SizedBox(height: 24),
            if (error != null) ...[
              EmptyState(
                icon: Icons.cloud_off,
                title: l10n.protectionSyncError,
                hint: AppMessages.friendlyMessage(context, error!),
                actionLabel: l10n.retry,
                onAction: onRefresh,
              ),
              const SizedBox(height: 24),
            ],
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

/// Wireframe profile header: monogram avatar + greeting/name/status + settings.
class _DashboardProfileHeader extends StatelessWidget {
  const _DashboardProfileHeader({
    required this.auth,
    required this.status,
    required this.onRefresh,
    required this.refreshing,
  });

  final AuthState auth;
  final ProtectionStatus? status;
  final Future<void> Function() onRefresh;
  final bool refreshing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final name = auth.displayName?.trim() ?? '';
    final firstName = name.split(' ').first;
    final greeting = name.isNotEmpty
        ? l10n.dashboardHello(firstName)
        : l10n.dashboardHelloGuest;
    final active = status?.isActive == true;
    final role = active
        ? l10n.protectionStatusActive
        : l10n.protectionStatusInactive;

    return Row(
      children: [
        MonogramAvatar(
          label: name.isNotEmpty ? name : 'G',
          color: AppColors.navy,
          size: 48,
          boxShadow: AppColors.cardSoftShadow,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.inkMuted,
                ),
              ),
              Text(
                name.isNotEmpty ? name : l10n.dashboardHelloGuest,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              Text(
                role,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.inkMuted,
                ),
              ),
            ],
          ),
        ),
        _HeaderIconButton(
          tooltip: l10n.refresh,
          icon: Icons.refresh_rounded,
          onPressed: refreshing ? null : () => onRefresh(),
        ),
        const SizedBox(width: 8),
        _HeaderIconButton(
          tooltip: l10n.settingsTitle,
          icon: Icons.settings_rounded,
          onPressed: () => context.go('/settings'),
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback? onPressed;

  const _HeaderIconButton({
    required this.tooltip,
    required this.icon,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      customBorder: const CircleBorder(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: AppColors.cardSoftShadow,
        ),
        child: Icon(
          icon,
          size: AppIconSize.md,
          color: onPressed == null ? AppColors.inkMuted : AppColors.ink,
        ),
      ),
    );
  }
}

/// Light "overview banner": status headline + Gami illustration with a
/// gradient fade, plus a setup CTA (mirrors the wireframe banner + hero).
class _StatusBanner extends ConsumerWidget {
  const _StatusBanner({
    required this.auth,
    required this.status,
    required this.onOpenSetup,
  });

  final AuthState auth;
  final ProtectionStatus? status;
  final VoidCallback onOpenSetup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstOpenToday =
        ref.watch(firstOpenTodayProvider).valueOrNull ?? false;
    final gami = resolveDashboardGami(firstOpenToday: firstOpenToday);
    final l10n = AppLocalizations.of(context)!;
    final active = status?.isActive == true;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.banner),
        border: Border.all(color: AppColors.background),
        boxShadow: AppColors.cardSoftShadow,
      ),
      child: Stack(
        children: [
          const Positioned(
            top: -50,
            left: -50,
            child: RadialBlob(color: AppColors.blueAccent, size: 220, alpha: 0.16),
          ),
          const Positioned(
            top: -30,
            right: -50,
            child: RadialBlob(color: AppColors.violetAccent, size: 190, alpha: 0.12),
          ),
          Positioned(
            right: -8,
            bottom: -12,
            child: Image.asset(
              gami.asset,
              height: 118,
              cacheWidth: 300,
              excludeFromSemantics: true,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/images/gami.webp',
                height: 118,
                cacheWidth: 300,
                excludeFromSemantics: true,
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: 150,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [Color(0xFFFFFFFF), Color(0xCCFFFFFF), Color(0x00FFFFFF)],
                  stops: [0, 0.5, 1],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: active ? AppColors.sage : AppColors.crimson,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      active
                          ? l10n.protectionStatusActive
                          : l10n.protectionStatusInactive,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.55,
                  child: Text(
                    active
                        ? l10n.protectionActiveTitle
                        : l10n.protectionInactiveTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                          fontSize: 22,
                        ),
                  ),
                ),
                const SizedBox(height: 6),
                SizedBox(
                  width: MediaQuery.sizeOf(context).width * 0.56,
                  child: Text(
                    l10n.protectionOnDevicePrivacyDesc,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.45,
                      color: AppColors.inkMuted,
                    ),
                  ),
                ),
                if (gami.lineBuilder != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    gami.lineBuilder!(l10n),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blueAccent,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                SizedBox(
                  height: 38,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
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
            ),
          ),
        ],
      ),
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
                      await ref
                          .read(authProvider.notifier)
                          .startPhoneVerification(_phoneController.text);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.verifyEmailSent)),
                        );
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
