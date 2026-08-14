import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/features/settings/presentation/widgets/avatar_photo_action_dialog.dart';
import 'package:gamblock_ai_apps/l10n/app_localizations.dart';

void main() {
  testWidgets('renders avatar action dialog with gallery, camera, and remove options', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    AvatarPhotoAction? selectedAction;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('id'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                selectedAction = await showAvatarPhotoActionDialog(
                  context,
                  name: 'Gading',
                  avatarUrl: 'https://example.com/avatar.jpg',
                  avatarVersion: 1,
                  canUseCamera: true,
                );
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Foto profil'), findsOneWidget);
    expect(
      find.text('Pilih cara untuk memperbarui foto profil Anda.'),
      findsOneWidget,
    );
    expect(find.text('Pilih dari galeri'), findsOneWidget);
    expect(find.text('Ambil foto'), findsOneWidget);
    expect(find.text('Hapus foto'), findsOneWidget);
    expect(find.byIcon(Icons.close_rounded), findsOneWidget);

    // Tap choose gallery
    await tester.tap(find.text('Pilih dari galeri'));
    await tester.pumpAndSettle();

    expect(selectedAction, equals(AvatarPhotoAction.gallery));
  });

  testWidgets('switching to confirming delete shows delete warning and buttons', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    AvatarPhotoAction? selectedAction;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('id'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                selectedAction = await showAvatarPhotoActionDialog(
                  context,
                  name: 'Gading',
                  avatarUrl: 'https://example.com/avatar.jpg',
                  avatarVersion: 1,
                  canUseCamera: false,
                );
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    expect(find.text('Ambil foto'), findsNothing); // camera not available
    expect(find.text('Hapus foto'), findsOneWidget);

    // Tap delete tile
    await tester.tap(find.text('Hapus foto'));
    await tester.pumpAndSettle();

    expect(find.text('Hapus foto profil?'), findsOneWidget);
    expect(
      find.text(
        'Foto profil Anda akan dihapus dan diganti dengan inisial nama.',
      ),
      findsOneWidget,
    );
    expect(find.text('Batal'), findsOneWidget);

    // Tap confirm delete
    await tester.tap(find.widgetWithText(FilledButton, 'Hapus foto'));
    await tester.pumpAndSettle();

    expect(selectedAction, equals(AvatarPhotoAction.delete));
  });
}
