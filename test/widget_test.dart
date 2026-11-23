import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/screens/achievement_form.dart';
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

Future<void> openAchievementForm(WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  await tester.ensureVisible(find.text('Add Achievement'));
  await tester.tap(find.text('Add Achievement'));
  await settleRoute(tester);
  // The card's SnackBar stays on screen for about 4 seconds; let it go away.
  await tester.pump(const Duration(seconds: 5));
  await tester.pumpAndSettle();
}

/// The four text inputs of the achievement form, in screen order.
Finder titleField() => find.byType(TextFormField).at(0);
Finder eventField() => find.byType(TextFormField).at(1);
Finder descriptionField() => find.byType(TextFormField).at(2);
Finder yearField() => find.byType(TextFormField).at(3);

Future<void> fillAchievementForm(
  WidgetTester tester, {
  String title = 'Gold Medalist of Math Competition',
  String event = 'ONSB 2025',
  String description = 'Won the gold medal.',
  String year = '2025',
}) async {
  await tester.enterText(titleField(), title);
  await tester.enterText(eventField(), event);
  await tester.enterText(descriptionField(), description);
  await tester.enterText(yearField(), year);
}

Future<void> pressSave(WidgetTester tester) async {
  await tester.ensureVisible(find.text('Save'));
  await tester.tap(find.text('Save'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
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

  group('Achievement form', () {
    testWidgets('the Add Achievement card opens the form, Back returns home', (
      tester,
    ) async {
      await openAchievementForm(tester);

      expect(find.byType(AchievementFormPage), findsOneWidget);
      expect(find.text('Add Achievement Form'), findsOneWidget);

      await pressSystemBack(tester);
      expect(find.byType(AchievementFormPage), findsNothing);
      expect(find.byType(MyHomePage), findsOneWidget);
    });

    testWidgets(
      'the drawer opens the form and Home returns to the home screen',
      (tester) async {
        await tester.pumpWidget(const MyApp());

        await tester.tap(find.byTooltip('Open navigation menu'));
        await tester.pumpAndSettle();
        // The drawer keeps Home and Add Project and adds Add Achievement.
        expect(find.widgetWithText(ListTile, 'Home'), findsOneWidget);
        expect(find.widgetWithText(ListTile, 'Add Project'), findsOneWidget);
        await tester.tap(find.widgetWithText(ListTile, 'Add Achievement'));
        await tester.pumpAndSettle();
        expect(find.byType(AchievementFormPage), findsOneWidget);

        // The same drawer is on the form, and Home goes back to the home screen.
        await tester.tap(find.byTooltip('Open navigation menu'));
        await tester.pumpAndSettle();
        expect(
          find.widgetWithText(ListTile, 'Add Achievement'),
          findsOneWidget,
        );
        await tester.tap(find.widgetWithText(ListTile, 'Home'));
        await tester.pumpAndSettle();
        expect(find.byType(MyHomePage), findsOneWidget);
        expect(find.byType(AchievementFormPage), findsNothing);
      },
    );

    testWidgets('has at least three inputs matching the Achievement model', (
      tester,
    ) async {
      await openAchievementForm(tester);

      expect(find.byType(TextFormField), findsNWidgets(4));
      expect(find.byType(DropdownButtonFormField<String>), findsOneWidget);
      for (final label in [
        'Title',
        'Event',
        'Category',
        'Description',
        'Year',
      ]) {
        expect(find.text(label), findsOneWidget);
      }
    });

    testWidgets('Save with every field empty shows an error for each field', (
      tester,
    ) async {
      await openAchievementForm(tester);
      await pressSave(tester);

      expect(find.text('Enter the title.'), findsOneWidget);
      expect(find.text('Enter the event.'), findsOneWidget);
      expect(find.text('Enter the description.'), findsOneWidget);
      expect(find.text('Enter the year.'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('rejects values that are only spaces', (tester) async {
      await openAchievementForm(tester);
      await fillAchievementForm(tester, title: '   ', event: '  ');
      await pressSave(tester);

      expect(find.text('Enter the title.'), findsOneWidget);
      expect(find.text('Enter the event.'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
    });

    testWidgets('rejects HTML tags and text longer than 255 characters', (
      tester,
    ) async {
      await openAchievementForm(tester);
      await fillAchievementForm(
        tester,
        title: '<b>Winner</b>',
        event: 'a' * 256,
      );
      await pressSave(tester);

      expect(
        find.text('The title must not contain HTML tags.'),
        findsOneWidget,
      );
      expect(
        find.text('The event must be at most 255 characters.'),
        findsOneWidget,
      );
      expect(find.byType(AlertDialog), findsNothing);
    });

    for (final year in ['3000', '1800']) {
      testWidgets('rejects the year $year (outside 1900 to 2100)', (
        tester,
      ) async {
        await openAchievementForm(tester);
        await fillAchievementForm(tester, year: year);
        await pressSave(tester);

        expect(
          find.text('The year must be between 1900 and 2100.'),
          findsOneWidget,
        );
        expect(find.byType(AlertDialog), findsNothing);
      });
    }

    testWidgets('only digits can be typed in the year field', (tester) async {
      await openAchievementForm(tester);
      await fillAchievementForm(tester, year: '20a2');
      await pressSave(tester);

      // "20a2" becomes "202", which is below 1900 and is rejected.
      expect(
        find.text('The year must be between 1900 and 2100.'),
        findsOneWidget,
      );
    });

    testWidgets(
      'valid input shows every value in a dialog, OK resets the form',
      (tester) async {
        await openAchievementForm(tester);
        await fillAchievementForm(tester);
        // Pick the second category.
        await tester.tap(find.byType(DropdownButtonFormField<String>));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Non-Academic').last);
        await tester.pumpAndSettle();
        await pressSave(tester);

        expect(find.text('Achievement added successfully!'), findsOneWidget);
        expect(
          find.text('Title: Gold Medalist of Math Competition'),
          findsOneWidget,
        );
        expect(find.text('Event: ONSB 2025'), findsOneWidget);
        expect(find.text('Category: Non-Academic'), findsOneWidget);
        expect(find.text('Description: Won the gold medal.'), findsOneWidget);
        expect(find.text('Year: 2025'), findsOneWidget);

        await tester.tap(find.text('OK'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        // Back on the (now empty) form.
        expect(find.byType(AlertDialog), findsNothing);
        expect(find.byType(AchievementFormPage), findsOneWidget);
        // Every input is empty again (the hint text is not the field's value).
        final values = tester
            .widgetList<EditableText>(find.byType(EditableText))
            .map((field) => field.controller.text);
        expect(values.every((text) => text.isEmpty), isTrue);
      },
    );

    testWidgets('Save stays reachable on a phone with the keyboard open', (
      tester,
    ) async {
      addTearDown(tester.view.reset);
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(360, 640);
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);

      await openAchievementForm(tester);
      await pressSave(tester);

      expect(find.text('Enter the title.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
