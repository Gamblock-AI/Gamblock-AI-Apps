import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/auth/auth_state.dart';
import '../core/device/aggregate_sync.dart';
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
  String? _pendingApprovalLocation;

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
      if (event.type == 'intervention_required' ||
          event.type == 'intervention_shown') {
        unawaited(_flushCurrentAggregate());
        final nativeId =
            event.payload['intervention_id']?.toString().trim() ?? '';
        final interventionId = nativeId.isNotEmpty
            ? nativeId
            : 'legacy-${DateTime.now().microsecondsSinceEpoch}';
        router.go(
          Uri(
            path: '/pattern-interrupt',
            queryParameters: {'intervention_id': interventionId},
          ).toString(),
        );
      } else if (event.type == 'approval_required') {
        final action = event.payload['tamper_action']?.toString().trim() ?? '';
        final nativeId = event.payload['action_id']?.toString().trim() ?? '';
        final location = Uri(
          path: '/dashboard',
          queryParameters: {
            if (action.isNotEmpty) 'approval_action': action,
            if (nativeId.isNotEmpty) 'approval_id': nativeId,
          },
        ).toString();
        if (ref.read(authProvider).isAuthenticated) {
          router.go(location);
        } else {
          _pendingApprovalLocation = location;
          router.go('/login');
        }
      }
    });
  }

  Future<void> _flushCurrentAggregate() async {
    final auth = ref.read(authProvider);
    if (!auth.isAuthenticated) return;
    await AggregateSync.flushCurrentDay(auth.deviceId);
  }

  void _resumePendingApproval(AuthState auth) {
    final location = _pendingApprovalLocation;
    if (!auth.isAuthenticated || location == null) return;
    _pendingApprovalLocation = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(routerProvider).go(location);
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authProvider, (_, next) {
      _resumePendingApproval(next);
    });
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

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _interventionSub?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      PlatformBridge.ensureBackgroundProtection().catchError((_) => false);
      unawaited(_flushCurrentAggregate());
      if (ref.read(authProvider).isAuthenticated) {
        ref.read(authProvider.notifier).refreshProfile().catchError((_) {});
      }
    }
  }
}
