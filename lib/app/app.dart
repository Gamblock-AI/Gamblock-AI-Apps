import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme/app_theme.dart';
import '../core/auth/auth_state.dart';
import '../core/network/api_client.dart';
import 'router.dart';

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

    if (authState.isLoading) {
      return MaterialApp(
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return MaterialApp.router(
      title: 'Gamblock AI',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
