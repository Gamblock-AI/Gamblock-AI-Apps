import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/core/widgets/pressable.dart';

void main() {
  testWidgets('Pressable fires onTap', (tester) async {
    var tapped = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Pressable(onTap: () => tapped++, child: const Text('Tekan')),
        ),
      ),
    );
    await tester.tap(find.text('Tekan'));
    await tester.pump();
    expect(tapped, 1);
  });

  testWidgets('Pressable renders child', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Pressable(child: const Text('A'))),
      ),
    );
    expect(find.text('A'), findsOneWidget);
  });
}
