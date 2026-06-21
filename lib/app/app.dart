import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/auth/auth_state.dart';
import '../core/network/api_client.dart';
import 'router.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

class GamblockApp extends ConsumerStatefulWidget {
  const GamblockApp({super.key});
  @override
  ConsumerState<GamblockApp> createState() => _GamblockAppState();
}

class _GamblockAppState extends ConsumerState<GamblockApp> {
  @override
  void initState() {
    super.initState();
    ApiClient.init();
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(routerProvider);
    final authState = ref.watch(authProvider);

    final localizationsDelegates = const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ];

    final supportedLocales = const [
      Locale('id', ''),
      Locale('en', ''),
    ];

    if (authState.isLoading) {
      return MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        localizationsDelegates: localizationsDelegates,
        supportedLocales: supportedLocales,
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp.router(
      title: AppLocalizations.of(context)!.appName,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      localizationsDelegates: localizationsDelegates,
      supportedLocales: supportedLocales,
      routerConfig: router,
    );
  }
}
