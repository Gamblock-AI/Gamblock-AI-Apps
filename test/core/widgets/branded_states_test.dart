import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/core/widgets/app_busy_indicator.dart';
import 'package:gamblock_ai_apps/core/widgets/empty_state.dart';
import 'package:gamblock_ai_apps/core/widgets/gami_image.dart';
import 'package:gamblock_ai_apps/core/widgets/mesh_background.dart';

void main() {
  testWidgets('error state carries tone, mascot, action, and live semantics', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: EmptyState(
            icon: Icons.cloud_off_rounded,
            title: 'Tidak dapat memuat',
            hint: 'Coba lagi.',
            tone: AppStateTone.error,
            actionLabel: 'Ulangi',
            onAction: () {},
          ),
        ),
      ),
    );

    expect(find.byType(GamiImage), findsOneWidget);
    expect(find.text('Ulangi'), findsOneWidget);
    expect(
      tester
          .getSemantics(find.byType(EmptyState))
          .getSemanticsData()
          .flagsCollection
          .isLiveRegion,
      isTrue,
    );
    semantics.dispose();
  });

  testWidgets('strong mesh and busy state honor reduced motion', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: const MeshBackground(
            intensity: MeshBackgroundIntensity.strong,
            child: Center(child: AppBusyIndicator()),
          ),
        ),
      ),
    );

    expect(find.byKey(const ValueKey('app-blue-backdrop')), findsOneWidget);
    expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNothing);
  });
}
