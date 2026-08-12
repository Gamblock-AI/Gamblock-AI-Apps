import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/auth/auth_state.dart';
import '../core/notifications/daily_reminder_service.dart';
import '../core/platform/platform_bridge.dart';
import '../core/settings/app_settings.dart';
import 'router.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

class GamblockApp extends ConsumerStatefulWidget {
  const GamblockApp({super.key});
  @override
  ConsumerState<GamblockApp> createState() => _GamblockAppState();
}

class _GamblockAppState extends ConsumerState<GamblockApp>
    with WidgetsBindingObserver {
  StreamSubscription? _interventionSub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    DailyReminderService.onNotificationTap = () async {
      if (!mounted) return;
      ref.read(routerProvider).go('/dashboard');
    };
    _interventionSub = PlatformBridge.events().listen((event) {
      final router = ref.read(routerProvider);
      if (event.type == 'intervention_shown') {
        if (event.payload['native_overlay'] != true) {
          router.go('/pattern-interrupt');
          final evidenceId = event.payload['evidence_id']?.toString() ?? '';
          if (evidenceId.isNotEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              unawaited(PlatformBridge.recordInterventionCommitted(evidenceId));
            });
          }
        }
      } else if (event.type == 'approval_required') {
        router.go('/dashboard');
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _interventionSub?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        ref.read(authProvider).isAuthenticated) {
      ref.read(authProvider.notifier).refreshProfile().catchError((_) {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final settings = ref.watch(appSettingsProvider);

    final localizationsDelegates = const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ];

    final supportedLocales = const [Locale('id', ''), Locale('en', '')];

    // Single-phase boot: the router exists from the first frame. While boot
    // providers load, the root route shows [BootGate]'s spinner and the
    // redirect handles the real destination. This keeps a non-router
    // MaterialApp (which would read the web URL fragment as an initial
    // named route) from ever mounting.
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appName,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      localizationsDelegates: localizationsDelegates,
      supportedLocales: supportedLocales,
      locale: settings.locale,
      routerConfig: router,
    );
  }
}
