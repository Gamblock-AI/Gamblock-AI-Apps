import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/features/mini_games/presentation/widgets/twin_trace_card.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(width: 80, height: 80, child: child),
      ),
    ),
  );
}

void main() {
  testWidgets('TwinTraceCard renders image with BoxFit.cover and full size when face is shown', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        TwinTraceCard(
          fruitId: 'banana',
          showFace: true,
          semanticLabel: 'Banana',
          onTap: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final imageFinder = find.byKey(const ValueKey('face'));
    expect(imageFinder, findsOneWidget);

    final imageWidget = tester.widget<Image>(imageFinder);
    expect(imageWidget.fit, BoxFit.cover);
    expect(imageWidget.width, double.infinity);
    expect(imageWidget.height, double.infinity);
  });

  testWidgets('TwinTraceCard renders question icon when back is shown', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        TwinTraceCard(
          fruitId: 'banana',
          showFace: false,
          semanticLabel: 'Hidden card',
          onTap: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.question_mark_rounded), findsOneWidget);
  });
}
