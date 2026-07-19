import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/auth_state.dart';
import '../features/accountability/presentation/screens/accountability_screen.dart';
import '../features/analytics/presentation/screens/analytics_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/intro/presentation/screens/intro_screen.dart';
import '../features/intro/data/onboarding_state.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/pattern_interrupt/presentation/screens/pattern_interrupt_screen.dart';
import '../features/protection/presentation/screens/protection_screen.dart';
import '../features/recovery/presentation/screens/recovery_handoff_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/setup/presentation/screens/setup_screen.dart';
import 'shell.dart';

Page<void> _page({required LocalKey key, required Widget child}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (MediaQuery.disableAnimationsOf(context)) return child;
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position:
              Tween<Offset>(
                begin: const Offset(0, 0.025),
                end: Offset.zero,
              ).animate(
                CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
              ),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 220),
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);
  final onboarding = ref.watch(onboardingProvider);

  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final path = state.uri.path;
      if (authState.isLoading || onboarding.isLoading) return null;
      if (path == '/') {
        if (!onboarding.isCompleted) return '/intro';
        return authState.isAuthenticated ? '/dashboard' : '/login';
      }
      if (path == '/protection') return '/dashboard';
      if (path == '/onboarding' || path == '/onboarding/create-group') {
        return '/intro';
      }
      final authEntry =
          path == '/login' || path == '/register' || path == '/forgot-password';
      if (!onboarding.isCompleted && path != '/intro') {
        return '/intro';
      }
      if (authState.isAuthenticated && (authEntry || path == '/intro')) {
        return '/dashboard';
      }
      final publicPath =
          authEntry ||
          path == '/intro' ||
          path == '/pattern-interrupt' ||
          path == '/recovery';
      if (!authState.isAuthenticated && !publicPath) {
        return '/login';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (_, state) => _page(
          key: state.pageKey,
          child: const Scaffold(body: SizedBox.shrink()),
        ),
      ),
      GoRoute(
        path: '/intro',
        pageBuilder: (_, state) =>
            _page(key: state.pageKey, child: const IntroScreen()),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (_, state) =>
            _page(key: state.pageKey, child: const LoginScreen()),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (_, state) =>
            _page(key: state.pageKey, child: const RegisterScreen()),
      ),
      GoRoute(
        path: '/forgot-password',
        pageBuilder: (_, state) =>
            _page(key: state.pageKey, child: const ForgotPasswordScreen()),
      ),
      GoRoute(
        path: '/setup',
        pageBuilder: (_, state) =>
            _page(key: state.pageKey, child: const SetupScreen()),
      ),
      GoRoute(
        path: '/pattern-interrupt',
        pageBuilder: (_, state) =>
            _page(key: state.pageKey, child: const PatternInterruptScreen()),
      ),
      GoRoute(
        path: '/recovery',
        pageBuilder: (_, state) =>
            _page(key: state.pageKey, child: const RecoveryHandoffScreen()),
      ),
      ShellRoute(
        builder: (_, __, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (_, state) =>
                _page(key: state.pageKey, child: const ProtectionScreen()),
          ),
          GoRoute(
            path: '/analytics',
            pageBuilder: (_, state) =>
                _page(key: state.pageKey, child: const AnalyticsScreen()),
          ),
          GoRoute(
            path: '/accountability',
            pageBuilder: (_, state) =>
                _page(key: state.pageKey, child: const AccountabilityScreen()),
          ),
          GoRoute(
            path: '/settings',
            pageBuilder: (_, state) =>
                _page(key: state.pageKey, child: const SettingsScreen()),
          ),
        ],
      ),
    ],
  );
});
