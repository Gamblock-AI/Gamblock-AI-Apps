import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/features/mini_games/presentation/screens/twin_trace_screen.dart';
import 'package:gamblock_ai_apps/features/mini_games/presentation/widgets/twin_trace_configuration.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

Widget _buildScreen() {
  return const ProviderScope(
    child: MaterialApp(
      locale: Locale('id'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: TwinTraceScreen()),
    ),
  );
}

void main() {
  testWidgets('requires a difficulty selection before Twin Trace starts', (
    tester,
  ) async {
    await tester.pumpWidget(_buildScreen());
    await tester.pump();

    expect(find.byType(TwinTraceConfiguration), findsOneWidget);
    expect(find.text('Pilih tingkat kesulitan'), findsOneWidget);
    expect(find.text('4x4'), findsOneWidget);
    expect(find.text('5x5'), findsOneWidget);
  });

  testWidgets('starts with the website-equivalent card preview', (
    tester,
  ) async {
    await tester.pumpWidget(_buildScreen());
    await tester.pump();

    await tester.tap(find.text('Mulai permainan'));
    await tester.pump();

    expect(
      find.text('Ingat posisi kartunya. Papan akan tertutup sebentar lagi.'),
      findsOneWidget,
    );
  });
}
