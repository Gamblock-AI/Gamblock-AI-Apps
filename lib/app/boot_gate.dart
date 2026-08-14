import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/auth/auth_state.dart';
import '../core/settings/app_settings.dart';
import '../core/widgets/app_busy_indicator.dart';
import '../core/widgets/mesh_background.dart';
import '../features/intro/data/onboarding_state.dart';

/// Splash stand-in shown on the root route while the boot providers load.
/// Once loading completes the router redirect picks the real destination
/// (intro, dashboard, or login), so this only needs to show a spinner.
class BootGate extends ConsumerWidget {
  const BootGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authLoading = ref.watch(authProvider).isLoading;
    final settingsLoading = ref.watch(appSettingsProvider).isLoading;
    final onboardingLoading = ref.watch(onboardingProvider).isLoading;

    if (authLoading || settingsLoading || onboardingLoading) {
      return const MeshBackground(
        intensity: MeshBackgroundIntensity.strong,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(child: AppBusyIndicator(size: 32)),
        ),
      );
    }
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: SizedBox.shrink(),
    );
  }
}
