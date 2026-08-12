import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/features/intro/presentation/widgets/intro_hero_surface.dart';

Widget _wrap({required double width, required double height}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: width,
          height: height,
          child: const IntroHeroSurface(
            asset: 'assets/images/gami-wave.webp',
            fallbackAsset: 'assets/images/gami.webp',
            child: Text('intro content'),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('hero surface keeps content visible in a wide layout', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(width: 760, height: 480));
    await tester.pump();

    expect(find.text('intro content'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('hero surface keeps content visible in a compact layout', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(width: 360, height: 560));
    await tester.pump();

    expect(find.text('intro content'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
