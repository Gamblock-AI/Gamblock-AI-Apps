import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/features/mini_games/presentation/widgets/mini_game_exit_dialog.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

Widget _buildHarness({required Future<void> Function(BuildContext context) onOpen}) {
  return MaterialApp(
    locale: const Locale('id'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => onOpen(context),
          child: const Text('Open Dialog'),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('MiniGameExitDialog renders title, body, and triggers cancel/stay button', (
    tester,
  ) async {
    bool? result;
    await tester.pumpWidget(
      _buildHarness(
        onOpen: (context) async {
          result = await showDialog<bool>(
            context: context,
            builder: (_) => const MiniGameExitDialog(),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    // Open dialog
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Keluar dari permainan?'), findsOneWidget);
    expect(
      find.text('Progres permainan saat ini akan diulang saat kamu keluar.'),
      findsOneWidget,
    );
    expect(find.text('Tetap bermain'), findsOneWidget);
    expect(find.text('Keluar & ulangi'), findsOneWidget);

    // Tap "Tetap bermain"
    await tester.tap(find.text('Tetap bermain'));
    await tester.pumpAndSettle();

    expect(result, isFalse);
    expect(find.text('Keluar dari permainan?'), findsNothing);
  });

  testWidgets('MiniGameExitDialog triggers confirm/exit button', (
    tester,
  ) async {
    bool? result;
    await tester.pumpWidget(
      _buildHarness(
        onOpen: (context) async {
          result = await showDialog<bool>(
            context: context,
            builder: (_) => const MiniGameExitDialog(),
          );
        },
      ),
    );
    await tester.pumpAndSettle();

    // Open dialog
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Tap "Keluar & ulangi"
    await tester.tap(find.text('Keluar & ulangi'));
    await tester.pumpAndSettle();

    expect(result, isTrue);
    expect(find.text('Keluar dari permainan?'), findsNothing);
  });
}
