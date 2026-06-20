import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/core/widgets/eyebrow_pill.dart';
import 'package:gamblock_ai_apps/core/widgets/glass_card.dart';
import 'package:gamblock_ai_apps/core/widgets/icon_chip.dart';

void main() {
  testWidgets('EyebrowPill renders uppercase label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: EyebrowPill(label: 'deteksi', color: Colors.red))),
    );
    expect(find.text('DETEKSI'), findsOneWidget);
  });

  testWidgets('GlassCard renders its child', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: GlassCard(child: const Text('isi')))),
    );
    expect(find.text('isi'), findsOneWidget);
  });

  testWidgets('IconChip renders the icon', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: Scaffold(body: IconChip(icon: Icons.star, color: Colors.amber))),
    );
    expect(find.byIcon(Icons.star), findsOneWidget);
  });
}
