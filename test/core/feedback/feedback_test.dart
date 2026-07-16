import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/core/feedback/feedback.dart';

void main() {
  testWidgets('AppFeedback.success shows a SnackBar with the message', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) {
              return ElevatedButton(
                onPressed: () => AppFeedback.success(ctx, 'Berhasil disimpan'),
                child: const Text('go'),
              );
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pump();
    expect(find.text('Berhasil disimpan'), findsOneWidget);
  });

  testWidgets('AppFeedback.error shows a SnackBar with the message', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (ctx) {
              return ElevatedButton(
                onPressed: () => AppFeedback.error(ctx, 'Gagal menyimpan'),
                child: const Text('go'),
              );
            },
          ),
        ),
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pump();
    expect(find.text('Gagal menyimpan'), findsOneWidget);
  });
}
