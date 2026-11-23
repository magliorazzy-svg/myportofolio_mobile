import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/menu.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/widgets/project_card.dart';

/// Lets a route transition (about 300 ms) finish without letting the
/// SnackBar (4 s) time out.
Future<void> settleRoute(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

/// Presses the system Back button (the AppBar shows the drawer icon instead of
/// a back arrow, so tester.pageBack() cannot be used here).
Future<void> pressSystemBack(WidgetTester tester) async {
  await tester.binding.handlePopRoute();
  await settleRoute(tester);
}

Future<void> openForm(WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  await tester.ensureVisible(find.text('Add Project'));
  await tester.tap(find.text('Add Project'));
  await settleRoute(tester);
}

void main() {
  group('Home screen', () {
    testWidgets('shows the three info cards with my identity', (tester) async {
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

    testWidgets('shows at least three menu cards including Logout', (
      tester,
    ) async {
      await tester.pumpWidget(const MyApp());

      expect(MyHomePage().items.length, greaterThanOrEqualTo(3));
      expect(find.byType(ItemCard), findsNWidgets(MyHomePage().items.length));
      expect(find.text('View Projects'), findsOneWidget);
      expect(find.text('Add Project'), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
    });

    testWidgets('pressing any menu card shows its SnackBar message', (
      tester,
    ) async {
      await tester.pumpWidget(const MyApp());

      for (final item in MyHomePage().items) {
        final card = find.text(item.name);
        await tester.ensureVisible(card);
        await tester.tap(card);
        await settleRoute(tester);
        expect(
          find.text('You pressed the ${item.name} button!'),
          findsOneWidget,
        );
        if (item.name == 'Add Project' || item.name == 'Add Achievement') {
          // These cards also navigate; go back to keep testing the others.
          expect(find.byType(MyHomePage), findsNothing);
          await pressSystemBack(tester);
        }
      }
    });

    testWidgets('each ItemCard is drawn with its own background color', (
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

    test('every menu item has a different color', () {
      final items = MyHomePage().items;
      final colors = items.map((item) => item.color).toSet();
      expect(colors.length, items.length);
    });

    testWidgets('the layout does not overflow on narrow and wide screens', (
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
  });

  group('Navigation', () {
    testWidgets('Add Project card opens the form and Back returns home', (
      tester,
    ) async {
      await openForm(tester);

      expect(find.byType(ProjectFormPage), findsOneWidget);
      expect(find.text('Add Project Form'), findsOneWidget);

      await pressSystemBack(tester);
      expect(find.byType(ProjectFormPage), findsNothing);
      expect(find.byType(MyHomePage), findsOneWidget);
    });

    testWidgets('the drawer links Home and Add Project', (tester) async {
      await tester.pumpWidget(const MyApp());

      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      expect(
        find.text('Explore personal projects and experiences!'),
        findsOneWidget,
      );
      expect(find.text('Home'), findsOneWidget);

      // Home -> Add Project through the drawer (pushReplacement).
      await tester.tap(find.widgetWithText(ListTile, 'Add Project'));
      await tester.pumpAndSettle();
      expect(find.byType(ProjectFormPage), findsOneWidget);

      // The form screen has the same drawer, so we can go back Home.
      await tester.tap(find.byTooltip('Open navigation menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ListTile, 'Home'));
      await tester.pumpAndSettle();
      expect(find.byType(MyHomePage), findsOneWidget);
      expect(find.byType(ProjectFormPage), findsNothing);
    });
  });

  group('Project form', () {
    testWidgets('rejects an empty name and description', (tester) async {
      await openForm(tester);

      await tester.ensureVisible(find.text('Save'));
      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(find.text('Enter a project name.'), findsOneWidget);
      expect(find.text('Enter a project description.'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('shows the entered data in a dialog and resets on OK', (
      tester,
    ) async {
      await openForm(tester);

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'My Portfolio App');
      await tester.enterText(fields.at(1), 'A Flutter portfolio');
      await tester.enterText(fields.at(2), 'Flutter, Django');
      await tester.enterText(fields.at(3), 'https://example.com');
      await tester.ensureVisible(find.text('Save'));
      await tester.tap(find.text('Save'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Project added successfully!'), findsOneWidget);
      expect(find.text('Project Name: My Portfolio App'), findsOneWidget);
      expect(find.text('Description: A Flutter portfolio'), findsOneWidget);
      expect(find.text('Category: Web Development'), findsOneWidget);
      expect(find.text('Technologies: Flutter, Django'), findsOneWidget);
      expect(find.text('Link: https://example.com'), findsOneWidget);

      await tester.tap(find.text('OK'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('My Portfolio App'), findsNothing);
    });
  });
}
