import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/features/intro/presentation/widgets/onboarding_slide.dart';

Widget _wrap({required double width, required double height}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          width: width,
          height: height,
          child: const OnboardingSlide(
            headerColor: Color(0xFF3DD6F5),
            headerDark: Color(0xFF2BB4D4),
            textColor: Color(0xFF0D1B35),
            markerColor: Color(0xFF0D1B35),
            asset: 'assets/images/gami-hug-heart.webp',
            lead: "DON'T FORGET TO",
            highlight: 'PROTECT',
            tail: 'YOURSELF',
            subtitle: 'On-device AI protection watches over every step.',
            stepBadge: 'STEP 1 OF 3',
            showHeart: true,
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('slide shows headline and mascot in a wide layout', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(width: 760, height: 480));
    await tester.pump();

    expect(find.text("DON'T FORGET TO"), findsOneWidget);
    expect(find.text('PROTECT'), findsOneWidget);
    expect(find.text('YOURSELF'), findsOneWidget);
    expect(find.byType(Image), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('slide shows badge, headline, subtitle, and mascot when compact', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(width: 360, height: 560));
    await tester.pump();

    expect(find.text('STEP 1 OF 3'), findsOneWidget);
    expect(find.text("DON'T FORGET TO"), findsOneWidget);
    expect(find.text('PROTECT'), findsOneWidget);
    expect(find.text('YOURSELF'), findsOneWidget);
    expect(
      find.text('On-device AI protection watches over every step.'),
      findsOneWidget,
    );
    expect(find.byType(Image), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('slide skips empty headline parts and the badge when omitted', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: OnboardingSlide(
            headerColor: Color(0xFF16294C),
            headerDark: Color(0xFF0D1B35),
            textColor: Colors.white,
            markerColor: Color(0xFF3DD6F5),
            asset: 'assets/images/gami-relax.webp',
            lead: "IT'S OKAY TO",
            highlight: 'TAKE A PAUSE',
            tail: '',
            subtitle: 'Pattern Interrupt gives you breathing room.',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text("IT'S OKAY TO"), findsOneWidget);
    expect(find.text('TAKE A PAUSE'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('tapping the mascot plays a bounce without errors', (
    tester,
  ) async {
    await tester.pumpWidget(_wrap(width: 360, height: 560));
    await tester.pump();

    await tester.tap(find.byType(Image));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(tester.takeException(), isNull);
  });
}
