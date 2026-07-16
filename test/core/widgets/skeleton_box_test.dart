import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/core/widgets/skeleton_box.dart';

void main() {
  testWidgets('SkeletonBox renders and pumps without error', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: const SkeletonBox(width: 100, height: 20)),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(SkeletonBox), findsOneWidget);
  });
}
