import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/menu.dart';

void main() {
  testWidgets('Home page shows the three info cards with my identity', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    final home = MyHomePage();
    expect(find.text('NPM'), findsOneWidget);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Class'), findsOneWidget);
    expect(find.text(home.npm), findsOneWidget);
    expect(find.text(home.nama), findsOneWidget);
    expect(find.text(home.kelas), findsOneWidget);
    expect(find.byType(InfoCard), findsNWidgets(3));
  });

  testWidgets('Home page shows at least three menu cards including Logout', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(MyHomePage().items.length, greaterThanOrEqualTo(3));
    expect(find.byType(ItemCard), findsNWidgets(MyHomePage().items.length));
    expect(find.text('View Projects'), findsOneWidget);
    expect(find.text('Add Project'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
  });

  testWidgets('Pressing any menu card shows its SnackBar message', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    for (final item in MyHomePage().items) {
      final card = find.text(item.name);
      await tester.ensureVisible(card);
      await tester.tap(card);
      await tester.pump();
      expect(find.text('You pressed the ${item.name} button!'), findsOneWidget);
    }
  });

  testWidgets('Each ItemCard is drawn with its own background color', (
    tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    for (final item in MyHomePage().items) {
      final material = tester.widget<Material>(
        find
            .descendant(
              of: find.ancestor(
                of: find.text(item.name),
                matching: find.byType(ItemCard),
              ),
              matching: find.byType(Material),
            )
            .first,
      );
      expect(material.color, item.color);
    }
  });

  test('Every menu item has a different color', () {
    final items = MyHomePage().items;
    final colors = items.map((item) => item.color).toSet();
    expect(colors.length, items.length);
  });

  testWidgets('The layout does not overflow on narrow and wide screens', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    tester.view.devicePixelRatio = 1.0;

    for (final size in const [
      Size(360, 640),
      Size(412, 915),
      Size(1280, 800),
    ]) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(const MyApp());
      await tester.pump();
      expect(tester.takeException(), isNull, reason: 'overflow at $size');
    }
  });
}
