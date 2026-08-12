import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gamblock_ai_apps/core/widgets/accent_carousel_card.dart';
import 'package:gamblock_ai_apps/core/widgets/app_section_header.dart';
import 'package:gamblock_ai_apps/core/widgets/avatar_stack.dart';
import 'package:gamblock_ai_apps/core/widgets/category_tab_bar.dart';
import 'package:gamblock_ai_apps/core/widgets/glass_search_field.dart';
import 'package:gamblock_ai_apps/core/widgets/image_banner_card.dart';
import 'package:gamblock_ai_apps/core/widgets/monogram_avatar.dart';
import 'package:gamblock_ai_apps/core/widgets/radial_blob_background.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('MonogramAvatar renders first letter uppercase', (tester) async {
    await tester.pumpWidget(_wrap(const MonogramAvatar(label: 'andi')));
    expect(find.text('A'), findsOneWidget);
  });

  testWidgets('AvatarStack renders overlapping initials', (tester) async {
    await tester.pumpWidget(
      _wrap(const AvatarStack(labels: ['Alice', 'Bob', 'Cara'], size: 24)),
    );
    expect(find.text('A'), findsOneWidget);
    expect(find.text('B'), findsOneWidget);
    expect(find.text('C'), findsOneWidget);
  });

  testWidgets('BlobBackground renders content above decor', (tester) async {
    await tester.pumpWidget(
      _wrap(const BlobBackground(child: Text('content'))),
    );
    expect(find.text('content'), findsOneWidget);
  });

  testWidgets('AppSectionHeader shows title and invokes arrow', (tester) async {
    var tapped = false;
    await tester.pumpWidget(
      _wrap(AppSectionHeader(title: 'Sections', onArrow: () => tapped = true)),
    );
    expect(find.text('Sections'), findsOneWidget);
    await tester.tap(find.byType(InkWell).last);
    expect(tapped, isTrue);
  });

  testWidgets('CategoryTabBar selects active tab and fires callback', (
    tester,
  ) async {
    var selected = -1;
    await tester.pumpWidget(
      _wrap(
        CategoryTabBar(
          tabs: const [CategoryTab(Icons.star, 'One'), CategoryTab(Icons.home, 'Two')],
          selectedIndex: 0,
          onSelected: (i) => selected = i,
          padding: EdgeInsets.zero,
        ),
      ),
    );
    expect(find.text('One'), findsOneWidget);
    expect(find.text('Two'), findsOneWidget);
    await tester.tap(find.text('Two'));
    expect(selected, 1);
  });

  testWidgets('GlassSearchField shows hint text', (tester) async {
    await tester.pumpWidget(
      _wrap(const GlassSearchField(hintText: 'Search everything')),
    );
    expect(find.text('Search everything'), findsOneWidget);
  });

  testWidgets('ImageBannerCard shows title and description', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const ImageBannerCard(
          title: 'Run Your Office',
          description: 'Automate everything',
          image: SizedBox(width: 100, height: 100),
        ),
      ),
    );
    expect(find.text('Run Your Office'), findsOneWidget);
    expect(find.text('Automate everything'), findsOneWidget);
  });

  testWidgets('AccentCarouselCard shows title, meta and footer', (tester) async {
    await tester.pumpWidget(
      _wrap(
        const AccentCarouselCard(
          title: 'HR Onboarding\nProcess',
          accentColor: Colors.purple,
          metaText: '9:00 AM',
          metaIcon: Icons.schedule_rounded,
          footerText: '4 members',
          footerIcon: Icons.people_outline,
        ),
      ),
    );
    expect(find.textContaining('HR Onboarding'), findsOneWidget);
    expect(find.text('9:00 AM'), findsOneWidget);
    expect(find.text('4 members'), findsOneWidget);
  });
}
