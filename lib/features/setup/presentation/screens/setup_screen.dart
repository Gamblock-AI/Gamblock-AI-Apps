import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

import '../../../../core/auth/auth_state.dart';
import '../../../../core/feedback/feedback.dart';
import '../../../../core/messaging/app_messages.dart';
import '../../../../core/platform/platform_bridge.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../../../../core/widgets/app_bar_title.dart';
import '../models/setup_step.dart';
import '../widgets/setup_step_card.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  ProtectionSnapshot _snapshot = ProtectionSnapshot.fallback;
  bool _loading = false;
  bool? _selfTestPassed;

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(_refresh);
  }

  Future<void> _refresh() async {
    final snapshot = await PlatformBridge.getProtectionSnapshot();
    if (mounted) setState(() => _snapshot = snapshot);
  }

  Future<void> _registerDevice() async {
    setState(() => _loading = true);
    try {
      await ref.read(authProvider.notifier).ensureDeviceRegistered();
      if (mounted) {
        AppFeedback.success(
          context,
          AppLocalizations.of(context)!.setupDeviceRegistered,
        );
      }
    } catch (error) {
      if (mounted) {
        AppFeedback.error(context, AppMessages.friendlyMessage(context, error));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _selfTest() async {
    setState(() => _loading = true);
    final result = await PlatformBridge.runLocalSelfTest();
    if (mounted) {
      setState(() {
        _selfTestPassed = result['passed'] == true;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final auth = ref.watch(authProvider);
    final steps = <SetupStep>[
      SetupStep(
        icon: Icons.privacy_tip_outlined,
        title: l10n.setupPrivacyTitle,
        body: l10n.setupPrivacyBody,
        isComplete: true,
      ),
      SetupStep(
        icon: Icons.account_circle_outlined,
        title: l10n.setupAccountTitle,
        body: auth.isAuthenticated
            ? l10n.setupAccountReady
            : l10n.setupAccountBody,
        isComplete: auth.isAuthenticated,
        onAction: auth.isAuthenticated ? null : () => context.go('/login'),
        actionLabel: auth.isAuthenticated ? null : l10n.authLoginBtn,
      ),
      SetupStep(
        icon: Icons.devices_outlined,
        title: l10n.setupDeviceTitle,
        body: auth.deviceId == null
            ? l10n.setupDeviceBody
            : l10n.setupDeviceReady(auth.deviceId!),
        isComplete: auth.deviceId != null,
        onAction: auth.isAuthenticated && auth.deviceId == null
            ? _registerDevice
            : null,
        actionLabel: auth.isAuthenticated && auth.deviceId == null
            ? l10n.setupDeviceAction
            : null,
      ),
      SetupStep(
        icon: Icons.accessibility_new,
        title: l10n.setupPlatformTitle,
        body: _snapshot.isActive || _snapshot.isPaused
            ? l10n.setupPlatformReady
            : l10n.setupPlatformBody,
        isComplete: _snapshot.isActive || _snapshot.isPaused,
        onAction: _snapshot.isActive || _snapshot.isPaused
            ? null
            : () async {
                await PlatformBridge.openPlatformSetup();
                await _refresh();
              },
        actionLabel: _snapshot.isActive || _snapshot.isPaused
            ? null
            : l10n.setupPlatformAction,
      ),
      SetupStep(
        icon: Icons.science_outlined,
        title: l10n.setupSelfTestTitle,
        body: _selfTestPassed == true
            ? l10n.selfTestPassed
            : _selfTestPassed == false
            ? l10n.selfTestFailed
            : l10n.setupSelfTestBody,
        isComplete: _selfTestPassed == true,
        onAction: _selfTest,
        actionLabel: l10n.selfTestAction,
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: AppBarTitle(icon: Icons.fact_check_rounded, title: l10n.setupTitle),
      ),
      body: ListView(
        padding: AppSpacing.screenPadding,
        children: [
          Text(
            l10n.setupIntro,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.inkMuted,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 20),
          for (var index = 0; index < steps.length; index++)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: SetupStepCard(
                index: index,
                step: steps[index],
                isLoading: _loading,
              ),
            ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () => context.go('/dashboard'),
            icon: const Icon(Icons.shield_outlined),
            label: Text(l10n.setupFinishAction),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.setupLimitations,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.mutedForeground),
          ),
        ],
      ),
    );
  }
}
