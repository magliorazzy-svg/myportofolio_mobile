import 'package:flutter_test/flutter_test.dart';
import 'package:myportofolio_mobile/main.dart';

void main() {
  testWidgets('Home page shows info cards and menu items', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('NPM'), findsOneWidget);
    expect(find.text('View Projects'), findsOneWidget);
    expect(find.text('Logout'), findsOneWidget);
  });
}