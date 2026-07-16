import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/core/widgets/empty_state.dart';

void main() {
  testWidgets('EmptyState renders title and hint', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmptyState(
            icon: Icons.inbox,
            title: 'Belum ada data',
            hint: 'Coba lagi nanti',
          ),
        ),
      ),
    );
    expect(find.text('Belum ada data'), findsOneWidget);
    expect(find.text('Coba lagi nanti'), findsOneWidget);
    expect(find.byIcon(Icons.inbox), findsOneWidget);
  });

  testWidgets('EmptyState renders without hint', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmptyState(icon: Icons.inbox, title: 'Kosong'),
        ),
      ),
    );
    expect(find.text('Kosong'), findsOneWidget);
  });
}
