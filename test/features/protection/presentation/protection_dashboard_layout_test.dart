import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/core/auth/auth_state.dart';
import 'package:gamblock_ai_apps/core/widgets/brand_widgets.dart';
import 'package:gamblock_ai_apps/features/accountability/domain/entities/accountability_models.dart';
import 'package:gamblock_ai_apps/features/protection/data/daily_presence_store.dart';
import 'package:gamblock_ai_apps/features/protection/data/providers.dart';
import 'package:gamblock_ai_apps/features/protection/domain/entities/protection_status.dart';
import 'package:gamblock_ai_apps/features/protection/presentation/widgets/protection_screen_body.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

const _activeStatus = ProtectionStatus(
  platform: 'android',
  status: 'active',
  serviceRunning: true,
  sensorStatus: 'connected',
  permissionStatus: 'granted',
  rulesetVersion: 'rules-v3',
  modelVersion: 'model-v2',
);

Widget _dashboard({required VoidCallback onOpenSetup}) {
  return ProviderScope(
    overrides: [
      firstOpenTodayProvider.overrideWith((ref) async => false),
      weeklyAppreciationProvider.overrideWith((ref) async => null),
    ],
    child: MaterialApp(
      locale: const Locale('id'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(context).copyWith(disableAnimations: true),
          child: Scaffold(
            body: ProtectionScreenBody(
              isLoading: false,
              isActionLoading: false,
              status: _activeStatus,
              error: null,
              auth: const AuthState(
                isLoading: false,
                displayName: 'Alya Putri',
              ),
              accountability: null,
              requests: const <ApprovalRequest>[],
              emergencyRequest: null,
              onRefresh: () async {},
              onOpenSetup: onOpenSetup,
              onRunSelfTest: () {},
              onRequestApproval: () {},
              onApplyApproval: (_) {},
              onManagePartner: () {},
              onRequestEmergency: () {},
              onEnterEmergencyKey: () {},
              onLogin: () {},
              onOpenAccountSetup: () {},
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('compact dashboard retains avatar, hero, and working actions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    var setupTaps = 0;
    await tester.pumpWidget(_dashboard(onOpenSetup: () => setupTaps++));
    await tester.pump();

    expect(find.byType(UserAvatar), findsOneWidget);
    expect(find.byKey(const ValueKey('dashboard-topbar')), findsOneWidget);
    expect(
      find.byKey(const ValueKey('protection-wellness-hero')),
      findsOneWidget,
    );
    final compactHeroImage = tester.widget<Image>(
      find.byKey(const ValueKey('protection-hero-background')),
    );
    expect(
      (compactHeroImage.image as AssetImage).assetName,
      'assets/images/protection-hero-portrait.webp',
    );
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('protection-wellness-hero')),
        matching: find.byType(GamiImage),
      ),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('dashboard-platform-setup-card')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('dashboard-self-test-card')),
      findsOneWidget,
    );
    expect(
      tester
          .getSize(find.byKey(const ValueKey('dashboard-platform-setup-card')))
          .height,
      144,
    );
    expect(find.text('Data penjelajahan tetap di perangkat'), findsNothing);

    await tester.tap(
      find.byKey(const ValueKey('dashboard-platform-setup-card')),
    );
    expect(setupTaps, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wide dashboard renders all sensor cards in one row', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_dashboard(onOpenSetup: () {}));
    await tester.pump();

    final wideHeroImage = tester.widget<Image>(
      find.byKey(const ValueKey('protection-hero-background')),
    );
    expect(
      (wideHeroImage.image as AssetImage).assetName,
      'assets/images/protection-hero-landscape.webp',
    );

    const sensorKeys = [
      ValueKey('protection-sensor-service'),
      ValueKey('protection-sensor-browser'),
      ValueKey('protection-sensor-permission'),
      ValueKey('protection-sensor-model'),
    ];
    final positions = sensorKeys
        .map((key) => tester.getTopLeft(find.byKey(key)))
        .toList();

    expect(positions.map((position) => position.dy).toSet(), hasLength(1));
    expect(positions[0].dx, lessThan(positions[1].dx));
    expect(positions[1].dx, lessThan(positions[2].dx));
    expect(positions[2].dx, lessThan(positions[3].dx));
    final sensorAssets = sensorKeys
        .map(
          (key) => tester
              .widget<GamiImage>(
                find.descendant(
                  of: find.byKey(key),
                  matching: find.byType(GamiImage),
                ),
              )
              .asset,
        )
        .toSet();
    expect(sensorAssets, {
      'assets/images/gami-sensor-service.webp',
      'assets/images/gami-sensor-browser.webp',
      'assets/images/gami-sensor-permission.webp',
      'assets/images/gami-sensor-model.webp',
    });
    expect(find.byType(UserAvatar), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
