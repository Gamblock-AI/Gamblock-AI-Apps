import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/auth/auth_state.dart';
import '../../../../core/messaging/app_messages.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/brand_widgets.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../accountability/domain/entities/accountability_models.dart';
import '../../../tour/presentation/tour_target.dart';
import '../../data/daily_presence_store.dart';
import '../../domain/entities/protection_status.dart';
import 'dashboard_gami.dart';
import 'protection_accountability_section.dart';
import 'protection_actions.dart';
import 'protection_screen_skeleton.dart';
import 'protection_sensors_grid.dart';
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final horizontalPadding = constraints.maxWidth >= 720 ? 32.0 : 24.0;
        return RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            key: const ValueKey('protection-dashboard-scroll'),
            cacheExtent: 3000,
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              20,
              horizontalPadding,
              148,
            ),
            children: [
              TourTarget(
                id: 'tour-welcome',
                child: _DashboardProfileHeader(auth: auth, status: status),
              ),
              const SizedBox(height: 20),
              if (auth.isAuthenticated && !auth.phoneVerified) ...[
                const _VerificationNotice(),
                const SizedBox(height: 18),
              ],
              if (isLoading && status == null)
                const ProtectionScreenSkeleton()
              else ...[
                _entrance(
                  context,
                  0,
                  TourTarget(
                    id: 'tour-hero',
                    child: _StatusBanner(
                      status: status,
                      onOpenSetup: onOpenSetup,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                const ProtectionWeeklyAppreciation(),
                _entrance(
                  context,
                  1,
                  ProtectionActions(
                    isLoading: isActionLoading,
                    onOpenSetup: onOpenSetup,
                    onRunSelfTest: onRunSelfTest,
                  ),
                ),
                const SizedBox(height: 28),
                _entrance(
                  context,
                  2,
                  TourTarget(
                    id: 'tour-protection',
                    child: ProtectionSensorsGrid(status: status),
                  ),
                ),
                const SizedBox(height: 28),
                if (error != null) ...[
                  EmptyState(
                    icon: Icons.cloud_off,
                    title: l10n.protectionSyncError,
                    hint: AppMessages.friendlyMessage(context, error!),
                    tone: AppStateTone.error,
                    actionLabel: l10n.retry,
                    onAction: onRefresh,
                    radius: AppRadius.banner,
                  ),
                  const SizedBox(height: 28),
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
      },
    );
  }
}

/// Profile header retained above the wellness dashboard composition.
class _DashboardProfileHeader extends StatelessWidget {
  const _DashboardProfileHeader({required this.auth, required this.status});

  final AuthState auth;
  final ProtectionStatus? status;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final name = auth.displayName?.trim() ?? '';
    final firstName = name.split(' ').first;
    final greeting = name.isNotEmpty
        ? l10n.dashboardHello(firstName)
        : l10n.dashboardHelloGuest;

    return Container(
      key: const ValueKey('dashboard-topbar'),
      constraints: const BoxConstraints(minHeight: 58),
      child: Row(
        children: [
          TourTarget(
            id: 'tour-profile',
            child: UserAvatar(
              name: name.isNotEmpty ? name : 'G',
              avatarUrl: auth.avatarUrl,
              avatarVersion: auth.avatarVersion,
              color: AppColors.navy,
              size: 50,
              boxShadow: AppColors.cardSoftShadow,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  greeting,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedForeground,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name.isNotEmpty ? name : l10n.dashboardHelloGuest,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 20,
                    height: 1.15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          _ProtectionIndicator(status: status),
        ],
      ),
    );
  }
}

/// Compact protection state pill in the dashboard header. Tapping it shows a
/// tooltip with the status label plus an on-device privacy note.
class _ProtectionIndicator extends StatefulWidget {
  const _ProtectionIndicator({required this.status});

  final ProtectionStatus? status;

  @override
  State<_ProtectionIndicator> createState() => _ProtectionIndicatorState();
}

class _ProtectionIndicatorState extends State<_ProtectionIndicator> {
  final _tooltipKey = GlobalKey<TooltipState>();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final status = widget.status;
    final active = status?.isActive == true;
    final paused = status?.isPaused == true;
    final degraded = status?.isDegraded == true;
    final unknown = status == null;

    final Color color;
    final IconData icon;
    final String label;
    if (unknown) {
      color = AppColors.mutedForeground;
      icon = Icons.help_outline_rounded;
      label = l10n.statusChipOff;
    } else if (active) {
      color = AppColors.sage;
      icon = Icons.shield_rounded;
      label = l10n.protectionStatusActive;
    } else if (paused) {
      color = AppColors.amber;
      icon = Icons.pause_circle_outline_rounded;
      label = l10n.protectionStatusPaused;
    } else if (degraded) {
      color = AppColors.amber;
      icon = Icons.gpp_maybe_rounded;
      label = l10n.protectionStatusDegraded;
    } else {
      color = AppColors.crimson;
      icon = Icons.shield_outlined;
      label = l10n.protectionStatusInactive;
    }

    final tooltip = unknown ? label : '$label · ${l10n.protectionStatusLocal}';

    return Tooltip(
      key: _tooltipKey,
      triggerMode: TooltipTriggerMode.manual,
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _tooltipKey.currentState?.ensureTooltipVisible(),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: Container(
              constraints: const BoxConstraints(minHeight: 44),
              padding: const EdgeInsets.symmetric(horizontal: 11),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.88),
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(color: color.withValues(alpha: 0.28)),
                boxShadow: AppColors.cardSoftShadow,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 15, color: color),
                  const SizedBox(width: 6),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 112),
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.1,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Navy wellness-focus hero containing the truthful local protection state.
class _StatusBanner extends ConsumerWidget {
  const _StatusBanner({required this.status, required this.onOpenSetup});

  final ProtectionStatus? status;
  final VoidCallback onOpenSetup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firstOpenToday =
        ref.watch(firstOpenTodayProvider).valueOrNull ?? false;
    final gami = resolveDashboardGami(firstOpenToday: firstOpenToday);
    final l10n = AppLocalizations.of(context)!;
    final active = status?.isActive == true;
    final paused = status?.isPaused == true;
    final degraded = status?.isDegraded == true;
    final headline = active
        ? l10n.protectionActiveTitle
        : paused
        ? l10n.protectionStatusPaused
        : degraded
        ? l10n.protectionStatusDegraded
        : l10n.protectionInactiveTitle;
    final accent = active
        ? AppColors.sage
        : paused || degraded
        ? AppColors.amber
        : AppColors.sky;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= 720;
        final contentWidth = isWide
            ? constraints.maxWidth * 0.56
            : constraints.maxWidth * 0.64;
        final backgroundAsset = isWide
            ? 'assets/images/protection-hero-landscape.webp'
            : 'assets/images/protection-hero-portrait.webp';

        return Container(
          key: const ValueKey('protection-wellness-hero'),
          constraints: BoxConstraints(minHeight: isWide ? 252 : 268),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: AppColors.navyGradient,
            borderRadius: BorderRadius.circular(AppRadius.banner),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withValues(alpha: 0.24),
                blurRadius: 30,
                offset: const Offset(0, 14),
                spreadRadius: -14,
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  backgroundAsset,
                  key: const ValueKey('protection-hero-background'),
                  fit: BoxFit.cover,
                  alignment: isWide
                      ? const Alignment(1, 0.2)
                      : Alignment.centerRight,
                  filterQuality: FilterQuality.high,
                  gaplessPlayback: true,
                  excludeFromSemantics: true,
                  errorBuilder: (context, error, stackTrace) =>
                      const DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: AppColors.navyGradient,
                        ),
                      ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          AppColors.navyDark.withValues(alpha: 0.98),
                          AppColors.navy.withValues(alpha: 0.91),
                          AppColors.navy.withValues(alpha: 0.18),
                          Colors.transparent,
                        ],
                        stops: const [0, 0.48, 0.76, 1],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(isWide ? 32 : 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: contentWidth),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        child: Text(
                          l10n.protectionTitle.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                            color: accent,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        headline,
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontSize: isWide ? 30 : 23,
                              fontWeight: FontWeight.w800,
                              height: 1.14,
                              letterSpacing: -0.5,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.protectionOnDevicePrivacyDesc,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.72),
                          fontSize: isWide ? 13 : 11.5,
                          height: 1.45,
                        ),
                      ),
                      if (gami.lineBuilder != null) ...[
                        const SizedBox(height: 10),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.only(top: 2),
                              child: Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 12,
                                color: AppColors.sky,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                gami.lineBuilder!(l10n),
                                style: TextStyle(
                                  fontSize: 10.5,
                                  height: 1.35,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.82),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 44,
                        child: FilledButton.icon(
                          key: const ValueKey('dashboard-check-setup'),
                          onPressed: onOpenSetup,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 44),
                            backgroundColor: AppColors.amber,
                            foregroundColor: AppColors.navyDark,
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            shape: const StadiumBorder(),
                            textStyle: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          icon: const Icon(Icons.tune_rounded, size: 16),
                          label: Text(l10n.checkSetupAction),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VerificationNotice extends ConsumerStatefulWidget {
  const _VerificationNotice();

  @override
  ConsumerState<_VerificationNotice> createState() =>
      _VerificationNoticeState();
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
    return SurfaceCard(
      radius: AppRadius.banner,
      color: AppColors.azure.withValues(alpha: 0.72),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.sky.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(
                  Icons.phone_rounded,
                  color: AppColors.navy,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  l10n.verifyEmailTitle,
                  style: const TextStyle(
                    color: AppColors.navy,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            l10n.verifyEmailBody,
            style: const TextStyle(
              color: AppColors.mutedForeground,
              height: 1.45,
            ),
          ),
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
                    final previewCode = await ref
                        .read(authProvider.notifier)
                        .startPhoneVerification(_phoneController.text);
                    if (context.mounted) {
                      setState(() => _previewCode = previewCode);
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
          if (_previewCode != null && _previewCode!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n.authVerifyPreviewCodeHint(_previewCode!),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.navy,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () async {
              try {
                await ref
                    .read(authProvider.notifier)
                    .confirmPhoneVerification(_codeController.text);
                if (context.mounted) {
                  setState(() {
                    _previewCode = null;
                    _codeController.clear();
                  });
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
            child: Text(l10n.verifyCode),
          ),
        ],
      ),
    );
  }
}
