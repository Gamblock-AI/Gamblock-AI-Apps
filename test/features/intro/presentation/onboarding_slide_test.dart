import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/features/intro/presentation/widgets/onboarding_slide.dart';

const _portraitAsset = 'assets/images/onboarding-protect-portrait.webp';
const _landscapeAsset = 'assets/images/onboarding-protect-landscape.webp';

Widget _wrap({
  required double width,
  required double height,
  bool disableAnimations = false,
  String tail = 'YOURSELF',
}) {
  return MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: disableAnimations),
      child: Scaffold(
        body: Center(
          child: SizedBox(
            width: width,
            height: height,
            child: OnboardingSlide(
              portraitAsset: _portraitAsset,
              landscapeAsset: _landscapeAsset,
              markerColor: const Color(0xFF3DD6F5),
              lead: "DON'T FORGET TO",
              highlight: 'PROTECT',
              tail: tail,
              subtitle: 'On-device AI protection watches over every step.',
              action: const SizedBox(
                key: ValueKey('test-action'),
                width: 56,
                height: 56,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

String _backgroundAsset(WidgetTester tester) {
  final image = tester.widget<Image>(
    find.byKey(const ValueKey('onboarding-background')),
  );
  return (image.image as AssetImage).assetName;
}

void main() {
  testWidgets('wide layout selects the landscape background', (tester) async {
    await tester.pumpWidget(_wrap(width: 760, height: 480));
    await tester.pumpAndSettle();

    expect(_backgroundAsset(tester), _landscapeAsset);
    expect(find.text("DON'T FORGET TO"), findsOneWidget);
    expect(find.text('PROTECT'), findsOneWidget);
    expect(find.text('YOURSELF'), findsOneWidget);
    expect(find.byKey(const ValueKey('test-action')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('compact layout selects portrait art without overflowing', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(width: 360, height: 560));
    await tester.pumpAndSettle();

    expect(_backgroundAsset(tester), _portraitAsset);
    expect(
      find.text('On-device AI protection watches over every step.'),
      findsOneWidget,
    );
    expect(find.byKey(const ValueKey('test-action')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('portrait tablet keeps the portrait composition', (tester) async {
    // The 800x1000 target is taller than the default 600px test surface; give
    // the viewport enough height so the SizedBox size is not clamped.
    tester.view.physicalSize = const Size(800, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_wrap(width: 800, height: 1000));
    await tester.pumpAndSettle();

    expect(_backgroundAsset(tester), _portraitAsset);
    expect(tester.takeException(), isNull);
  });

  testWidgets('empty headline parts and reduced motion remain valid', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(width: 390, height: 844, disableAnimations: true, tail: ''),
    );
    await tester.pump();

    expect(find.text("DON'T FORGET TO"), findsOneWidget);
    expect(find.text('PROTECT'), findsOneWidget);
    expect(find.text('YOURSELF'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
