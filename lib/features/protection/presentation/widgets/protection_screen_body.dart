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
import '../../data/daily_presence_store.dart';
import '../../domain/entities/protection_status.dart';
import 'dashboard_gami.dart';
import 'protection_accountability_section.dart';
import 'protection_actions.dart';
import 'protection_screen_skeleton.dart';
import 'protection_sensors_carousel.dart';
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
            const SizedBox(height: 24),
            _entrance(context, 2, ProtectionSensorsCarousel(status: status)),
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
  });

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

    return Row(
      children: [
        UserAvatar(
          name: name.isNotEmpty ? name : 'G',
          avatarUrl: auth.avatarUrl,
          avatarVersion: auth.avatarVersion,
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
            ],
          ),
        ),
        const SizedBox(width: 8),
        _ProtectionIndicator(status: status),
      ],
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

    final tooltip = unknown
        ? label
        : '$label · ${l10n.protectionStatusLocal}';

    return Tooltip(
      key: _tooltipKey,
      triggerMode: TooltipTriggerMode.manual,
      message: tooltip,
      child: InkWell(
        onTap: () => _tooltipKey.currentState?.ensureTooltipVisible(),
        customBorder: const CircleBorder(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            border: Border.all(color: color.withValues(alpha: 0.28)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Light overview banner matching website student dashboard header.
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
    final screenWidth = MediaQuery.sizeOf(context).width;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.azure.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppRadius.banner),
        border: Border.all(color: AppColors.navy.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Pastel atmospheric mesh gradient blobs
          const Positioned(
            top: -40,
            left: -40,
            child: RadialBlob(color: AppColors.sky, size: 200, alpha: 0.18),
          ),
          const Positioned(
            bottom: -30,
            right: -30,
            child: RadialBlob(color: AppColors.azure, size: 220, alpha: 0.35),
          ),
          // Gami mascot companion on the right (takes 70-75% of container height)
          Positioned(
            right: -10,
            top: 0,
            bottom: 0,
            child: Center(
              child: Image.asset(
                gami.asset,
                height: 195,
                cacheWidth: 500,
                fit: BoxFit.contain,
                excludeFromSemantics: true,
                errorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/images/gami.webp',
                  height: 195,
                  cacheWidth: 500,
                  fit: BoxFit.contain,
                  excludeFromSemantics: true,
                ),
              ),
            ),
          ),
          // Gradient fade for text readability
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: screenWidth * 0.72,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  colors: [
                    AppColors.mesh.withValues(alpha: 0.98),
                    AppColors.mesh.withValues(alpha: 0.88),
                    AppColors.mesh.withValues(alpha: 0.0),
                  ],
                  stops: const [0, 0.60, 1],
                ),
              ),
            ),
          ),
          // Main content column
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Eyebrow label
                Text(
                  l10n.protectionTitle.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                    color: AppColors.navyLight,
                  ),
                ),
                const SizedBox(height: 8),
                // Main Headline
                SizedBox(
                  width: screenWidth * 0.58,
                  child: Text(
                    active
                        ? l10n.protectionActiveTitle
                        : l10n.protectionInactiveTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppColors.ink,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                          fontSize: 20,
                          letterSpacing: -0.3,
                        ),
                  ),
                ),
                const SizedBox(height: 6),
                // Subtitle
                SizedBox(
                  width: screenWidth * 0.58,
                  child: Text(
                    l10n.protectionOnDevicePrivacyDesc,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: AppColors.mutedForeground,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                // Privacy Guarantee Badge (mirrors Image 1 reference)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5.5),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(color: AppColors.border.withValues(alpha: 0.95)),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.navy.withValues(alpha: 0.03),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        active ? Icons.shield_outlined : Icons.lock_outline_rounded,
                        size: 13,
                        color: active ? AppColors.sage : AppColors.navyLight,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        active
                            ? l10n.protectionStatusLocal
                            : l10n.protectionDataStaysOnDevice,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.navy,
                        ),
                      ),
                    ],
                  ),
                ),
                if (gami.lineBuilder != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.blueAccentSoft,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.blueAccent.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.chat_bubble_outline_rounded,
                          size: 12,
                          color: AppColors.skyDark,
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            gami.lineBuilder!(l10n),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.navy,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                // Setup CTA Button
                SizedBox(
                  height: 40,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                    onPressed: onOpenSetup,
                    icon: const Icon(Icons.tune_rounded, size: 16),
                    label: Text(
                      l10n.checkSetupAction,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        letterSpacing: 0.2,
                      ),
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
                  color: AppColors.azure,
                  borderRadius: BorderRadius.circular(AppRadius.banner),
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
