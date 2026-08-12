import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/auth/auth_state.dart';
import '../features/accountability/presentation/screens/accountability_screen.dart';
import '../features/analytics/presentation/screens/analytics_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/verify_phone_screen.dart';
import '../features/intro/presentation/screens/intro_screen.dart';
import '../features/intro/data/onboarding_state.dart';
import '../features/auth/presentation/screens/forgot_password_screen.dart';
import '../features/pattern_interrupt/presentation/screens/pattern_interrupt_screen.dart';
import '../features/protection/presentation/screens/protection_screen.dart';
import '../features/recovery/presentation/screens/recovery_handoff_screen.dart';
import '../features/settings/presentation/screens/settings_help_screen.dart';
import '../features/settings/presentation/screens/settings_privacy_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/setup/presentation/screens/setup_screen.dart';
import 'boot_gate.dart';
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

class RouterNotifier extends ChangeNotifier {
  RouterNotifier(this._ref) {
    _ref.listen<AuthState>(
      authProvider,
      (previous, next) {
        if (previous?.isAuthenticated != next.isAuthenticated ||
            previous?.isLoading != next.isLoading) {
          notifyListeners();
        }
      },
    );
    _ref.listen<OnboardingState>(
      onboardingProvider,
      (previous, next) {
        if (previous?.isCompleted != next.isCompleted ||
            previous?.isLoading != next.isLoading) {
          notifyListeners();
        }
      },
    );
  }

  final Ref _ref;
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    refreshListenable: notifier,
    initialLocation: '/',
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final onboarding = ref.read(onboardingProvider);
      final path = state.uri.path;
      if (authState.isLoading || onboarding.isLoading) return null;

      // Onboarding gate: until the intro is completed, only `/intro` is
      // reachable. This must take priority over auth routing so an
      // authenticated session cannot bounce `/intro` -> `/dashboard` -> `/intro`.
      if (!onboarding.isCompleted) {
        return path == '/intro' ? null : '/intro';
      }

      if (path == '/' || path == '/intro') {
        return authState.isAuthenticated ? '/dashboard' : '/login';
      }
      if (path == '/protection') return '/dashboard';
      if (path == '/onboarding' || path == '/onboarding/create-group') {
        return '/intro';
      }
      final authEntry = path == '/login' ||
          path == '/register' ||
          path == '/forgot-password' ||
          path == '/verify-phone';
      if (authState.isAuthenticated && authEntry) {
        return '/dashboard';
      }
      final publicPath =
          authEntry ||
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
        pageBuilder: (_, state) =>
            _page(key: state.pageKey, child: const BootGate()),
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
        path: '/verify-phone',
        pageBuilder: (_, state) {
          final extra = state.extra;
          return _page(
            key: state.pageKey,
            child: VerifyPhoneScreen(
              verificationToken:
                  extra is Map ? extra['verification_token']?.toString() : null,
              phone: extra is Map ? extra['phone']?.toString() ?? '' : '',
            ),
          );
        },
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
      GoRoute(
        path: '/settings/privacy',
        pageBuilder: (_, state) =>
            _page(key: state.pageKey, child: const SettingsPrivacyScreen()),
      ),
      GoRoute(
        path: '/settings/help',
        pageBuilder: (_, state) =>
            _page(key: state.pageKey, child: const SettingsHelpScreen()),
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
