import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/auth/auth_state.dart';
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

class _GamblockAppState extends ConsumerState<GamblockApp> {
  StreamSubscription? _interventionSub;

  @override
  void initState() {
    super.initState();
    _interventionSub = PlatformBridge.events().listen((event) {
      final router = ref.read(routerProvider);
      if (event.type == 'intervention_shown') {
        if (event.payload['native_overlay'] != true) {
          router.go('/pattern-interrupt');
        }
      } else if (event.type == 'approval_required') {
        router.go('/protection');
      }
    });
  }

  @override
  void dispose() {
    _interventionSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final authState = ref.watch(authProvider);
    final settings = ref.watch(appSettingsProvider);

    final localizationsDelegates = const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ];

    final supportedLocales = const [Locale('id', ''), Locale('en', '')];

    if (authState.isLoading || settings.isLoading) {
      return MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.light,
        localizationsDelegates: localizationsDelegates,
        supportedLocales: supportedLocales,
        locale: settings.locale,
        home: const Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    return MaterialApp.router(
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
