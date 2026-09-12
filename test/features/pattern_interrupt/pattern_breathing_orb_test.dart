import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/features/pattern_interrupt/presentation/widgets/pattern_breathing_orb.dart';

void main() {
  testWidgets('uses a solid white core behind the brand logo', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: PatternBreathingOrb(
          animation: const AlwaysStoppedAnimation<double>(0.5),
          progress: const AlwaysStoppedAnimation<double>(0.0),
          disableAnimations: true,
          semanticsLabel: 'Tarik napas',
        ),
      ),
    );

    final core = tester.widget<Container>(
      find.byKey(const ValueKey('pattern-interrupt-brand-core')),
    );
    final decoration = core.decoration! as BoxDecoration;

    expect(decoration.color, Colors.white);
    expect(decoration.gradient, isNull);

    final brandLogo = tester.widget<Image>(
      find.byKey(const ValueKey('pattern-interrupt-brand-logo')),
    );
    expect(
      (brandLogo.image as AssetImage).assetName,
      'assets/images/gamblock-1.png',
    );
  });
}
