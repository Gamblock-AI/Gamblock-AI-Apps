import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/features/pattern_interrupt/presentation/widgets/pattern_grounding_panel.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

void main() {
  Widget host({
    VoidCallback? onReturnToProtection,
    void Function(Duration elapsed)? onCompleted,
  }) {
    return MaterialApp(
      locale: const Locale('id'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: PatternGroundingPanel(
            onReturnToProtection: onReturnToProtection ?? () {},
            onCompleted: onCompleted,
          ),
        ),
      ),
    );
  }

  Future<void> tapNext(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(FilledButton, 'Lanjut'));
    await tester.pump();
  }

  testWidgets(
    'shows all five grounding steps with changing labels and progress',
    (tester) async {
      await tester.pumpWidget(host());

      expect(find.text('Langkah 1 dari 5'), findsOneWidget);
      expect(find.text('Lihat'), findsOneWidget);
      expect(
        find.text('Sebutkan lima hal yang bisa Anda lihat di sekitar Anda.'),
        findsOneWidget,
      );
      expect(find.text('5'), findsOneWidget);

      await tapNext(tester);
      expect(find.text('Langkah 2 dari 5'), findsOneWidget);
      expect(find.text('Rasakan'), findsOneWidget);
      expect(
        find.text('Sebutkan empat hal yang bisa Anda sentuh atau rasakan.'),
        findsOneWidget,
      );
      expect(find.text('4'), findsOneWidget);

      await tapNext(tester);
      expect(find.text('Langkah 3 dari 5'), findsOneWidget);
      expect(find.text('Dengar'), findsOneWidget);
      expect(
        find.text('Sebutkan tiga suara yang bisa Anda dengar saat ini.'),
        findsOneWidget,
      );
      expect(find.text('3'), findsOneWidget);

      await tapNext(tester);
      expect(find.text('Langkah 4 dari 5'), findsOneWidget);
      expect(find.text('Cium'), findsOneWidget);
      expect(
        find.text('Sebutkan dua aroma yang bisa Anda cium.'),
        findsOneWidget,
      );
      expect(find.text('2'), findsOneWidget);

      await tapNext(tester);
      expect(find.text('Langkah 5 dari 5'), findsOneWidget);
      expect(find.text('Lindungi'), findsOneWidget);
      expect(
        find.text('Sebutkan satu hal yang ingin Anda lindungi hari ini.'),
        findsOneWidget,
      );
      expect(find.text('1'), findsOneWidget);
      expect(find.widgetWithText(FilledButton, 'Selesai'), findsOneWidget);
    },
  );

  testWidgets('enters completion state and invokes onCompleted exactly once', (
    tester,
  ) async {
    var completedCalls = 0;
    Duration? elapsed;

    await tester.pumpWidget(
      host(
        onCompleted: (duration) {
          completedCalls += 1;
          elapsed = duration;
        },
      ),
    );

    for (var step = 0; step < 4; step++) {
      await tapNext(tester);
    }
    expect(completedCalls, 0);

    await tester.tap(find.widgetWithText(FilledButton, 'Selesai'));
    await tester.pump();

    expect(completedCalls, 1);
    expect(elapsed, isNotNull);
    expect(elapsed, greaterThanOrEqualTo(Duration.zero));
    expect(find.text('Latihan selesai'), findsOneWidget);
    expect(
      find.text(
        'Anda sudah hadir sepenuhnya di momen ini. Pilih langkah berikutnya dengan tenang.',
      ),
      findsOneWidget,
    );
    expect(find.text('Langkah 5 dari 5'), findsNothing);
    expect(
      find.widgetWithText(FilledButton, 'Selesai dan kembali'),
      findsOneWidget,
    );

    await tester.tap(find.widgetWithText(FilledButton, 'Selesai dan kembali'));
    await tester.pump();
    expect(completedCalls, 1);
  });

  testWidgets('returns to protection while the exercise is incomplete', (
    tester,
  ) async {
    var returnCalls = 0;
    await tester.pumpWidget(host(onReturnToProtection: () => returnCalls += 1));

    expect(
      find.widgetWithText(TextButton, 'Selesai dan kembali'),
      findsOneWidget,
    );
    await tester.tap(find.widgetWithText(TextButton, 'Selesai dan kembali'));
    await tester.pump();

    expect(returnCalls, 1);
    expect(find.text('Langkah 1 dari 5'), findsOneWidget);
  });

  testWidgets('returns to protection from the completed state', (tester) async {
    var returnCalls = 0;
    await tester.pumpWidget(host(onReturnToProtection: () => returnCalls += 1));

    for (var step = 0; step < 5; step++) {
      await tester.tap(
        find.widgetWithText(FilledButton, step == 4 ? 'Selesai' : 'Lanjut'),
      );
      await tester.pump();
    }

    expect(find.text('Latihan selesai'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Selesai dan kembali'));
    await tester.pump();

    expect(returnCalls, 1);
  });
}
