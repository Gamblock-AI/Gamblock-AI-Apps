import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/features/accountability/domain/entities/accountability_models.dart';
import 'package:gamblock_ai_apps/features/accountability/presentation/widgets/approval_request_history.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

void main() {
  const requests = [
    ApprovalRequest(
      id: 'request-1',
      deviceId: 'device-1',
      membershipId: 'membership-1',
      action: 'uninstall_detected',
      actionLabel: 'Allow protected app removal',
      status: 'approved',
      statusLabel: 'Approved',
      reason: 'Accessibility service disabled',
      durationMinutes: 0,
    ),
    ApprovalRequest(
      id: 'request-2',
      deviceId: 'device-1',
      membershipId: 'membership-1',
      action: 'pause_protection',
      actionLabel: 'Pause protection for 15 minutes',
      status: 'expired',
      statusLabel: 'Expired',
      reason: 'Troubleshooting app setup',
      durationMinutes: 15,
    ),
  ];

  testWidgets(
    'mobile request history resolves Indonesian localization from raw strings',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('id'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: ApprovalRequestHistory(requests: requests),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      expect(find.byIcon(Icons.history_rounded), findsWidgets);
      expect(find.text('Riwayat permintaan'), findsOneWidget);
      expect(find.text('Izinkan penghapusan aplikasi'), findsOneWidget);
      expect(find.text('Disetujui'), findsOneWidget);
      expect(find.text('Layanan aksesibilitas dinonaktifkan'), findsOneWidget);
      expect(find.text('Jeda perlindungan 15 menit'), findsOneWidget);
      expect(find.text('Kedaluwarsa'), findsOneWidget);
      expect(find.text('Perbaikan pengaturan aplikasi'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'mobile request history resolves English localization from raw strings',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(
            body: Padding(
              padding: EdgeInsets.all(16),
              child: ApprovalRequestHistory(requests: requests),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Request history'), findsOneWidget);
      expect(find.text('Allow protected app removal'), findsOneWidget);
      expect(find.text('Approved'), findsOneWidget);
      expect(find.text('Accessibility service disabled'), findsOneWidget);
      expect(find.text('Pause protection for 15 minutes'), findsOneWidget);
      expect(find.text('Expired'), findsOneWidget);
      expect(find.text('Troubleshooting app setup'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('pending approval request shows cancel button and triggers onCancel', (
    tester,
  ) async {
    ApprovalRequest? cancelled;
    const pendingRequest = ApprovalRequest(
      id: 'request-pending',
      deviceId: 'device-1',
      membershipId: 'membership-1',
      action: 'pause_protection',
      actionLabel: 'Pause protection',
      status: 'pending',
      statusLabel: 'Pending',
      reason: 'Testing protection',
      durationMinutes: 30,
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('id'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ApprovalRequestHistory(
            requests: const [pendingRequest],
            onCancel: (req) => cancelled = req,
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Menunggu'), findsOneWidget);
    expect(find.text('Jeda perlindungan 30 menit'), findsOneWidget);
    expect(find.text('Pengujian perlindungan'), findsOneWidget);
    expect(find.text('Batal'), findsOneWidget);

    await tester.tap(find.text('Batal'));
    await tester.pump();

    expect(cancelled, equals(pendingRequest));
  });
}
