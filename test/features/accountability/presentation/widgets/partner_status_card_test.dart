import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/features/accountability/domain/entities/accountability_models.dart';
import 'package:gamblock_ai_apps/features/accountability/presentation/widgets/partner_status_card.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

void main() {
  testWidgets('renders active partner card with connected chip and full subtitle without privacy badge', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const membership = AccountabilityMembership(
      id: 'mem-1',
      groupId: 'grp-1',
      groupName: 'Kelas Informatika C',
      partnerName: 'Suci',
      status: 'active',
      sharing: AccountabilitySharing(),
    );

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('id'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: PartnerStatusCard(membership: membership),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Suci'), findsOneWidget);
    expect(find.text('Terhubung'), findsOneWidget);
    expect(
      find.text(
        'Terhubung melalui grup Kelas Informatika C. Pendamping hanya menerima agregat yang Anda izinkan.',
      ),
      findsOneWidget,
    );
    // Verify privacy badge is removed
    expect(find.text('Privasi Terlindungi · Hanya Agregat'), findsNothing);
  });

  testWidgets('renders no-partner state when membership is null', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      const MaterialApp(
        locale: Locale('id'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Padding(
            padding: EdgeInsets.all(16),
            child: PartnerStatusCard(membership: null),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Belum ada pendamping aktif'), findsOneWidget);
    expect(find.text('Terhubung'), findsNothing);
    expect(find.text('Privasi Terlindungi · Hanya Agregat'), findsNothing);
  });
}
