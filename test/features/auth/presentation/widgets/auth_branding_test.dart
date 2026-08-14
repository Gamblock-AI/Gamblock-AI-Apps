import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/core/widgets/mesh_background.dart';
import 'package:gamblock_ai_apps/features/auth/presentation/widgets/auth_brand_lockup.dart';
import 'package:gamblock_ai_apps/features/auth/presentation/widgets/auth_screen_frame.dart';

Widget _wrap(Widget child) {
  return ProviderScope(child: MaterialApp(home: child));
}

void main() {
  testWidgets('auth lockup renders the prominent stacked Gamblock identity', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    addTearDown(semantics.dispose);

    await tester.pumpWidget(
      _wrap(const Scaffold(body: Center(child: AuthBrandLockup()))),
    );
    await tester.pump();

    final logoFinder = find.byKey(const ValueKey('auth-brand-logo'));
    final wordmarkFinder = find.byKey(const ValueKey('auth-brand-wordmark'));
    final logo = tester.widget<Image>(logoFinder);

    expect(
      (logo.image as AssetImage).assetName,
      'assets/images/gamblock-1.png',
    );
    expect(logo.height, 72);
    expect(find.bySemanticsLabel('Gamblock-AI'), findsOneWidget);
    expect(
      tester.getBottomLeft(logoFinder).dy,
      lessThan(tester.getTopLeft(wordmarkFinder).dy),
    );
    expect(
      tester.getCenter(logoFinder).dx,
      closeTo(tester.getCenter(wordmarkFinder).dx, 0.1),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'auth frame keeps the stronger backdrop scrollable on short screens',
    (tester) async {
      tester.view.physicalSize = const Size(360, 560);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _wrap(
          const AuthScreenFrame(
            child: SizedBox(
              height: 760,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Text('Form selesai'),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      final backdrop = tester.widget<MeshBackground>(
        find.byKey(const ValueKey('auth-backdrop')),
      );
      expect(backdrop.intensity, MeshBackgroundIntensity.strong);
      expect(find.byKey(const ValueKey('app-blue-backdrop')), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      await tester.drag(
        find.byType(SingleChildScrollView),
        const Offset(0, -400),
      );
      await tester.pump();

      expect(find.text('Form selesai'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
