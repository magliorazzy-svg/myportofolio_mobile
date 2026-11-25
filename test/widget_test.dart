import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/main.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/screens/login_screen.dart';
import 'package:myportofolio_mobile/screens/project_form.dart';
import 'package:myportofolio_mobile/screens/project_list_screen.dart';
import 'package:myportofolio_mobile/services/api_client.dart';

http.Response _json(Object body, int status) => http.Response.bytes(
  utf8.encode(jsonEncode(body)),
  status,
  headers: {'content-type': 'application/json'},
);

/// A fake Django backend, so no test touches the real network.
class FakeBackend {
  FakeBackend({this.projects = const []});

  List<Map<String, dynamic>> projects;
  final List<http.Request> requests = [];
  bool failProjectList = false;

  late final http.Client client = MockClient(_handle);

  Future<http.Response> _handle(http.Request request) async {
    requests.add(request);
    final path = request.url.path;

    if (path == '/api/v1/projects/' && request.method == 'GET') {
      if (failProjectList) return _json({'detail': 'Server error'}, 500);
      return _json(projects, 200);
    }
    if (path == '/api/v1/projects/' && request.method == 'POST') {
      if (request.headers['Authorization'] != 'Token abc') {
        return _json({'detail': 'Invalid token.'}, 401);
      }
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      return _json({'id': 'new-id', ...body}, 201);
    }
    if (path == '/api/v1/auth/token/') {
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      if (body['password'] == 'secret') return _json({'token': 'abc'}, 200);
      return _json({
        'non_field_errors': ['Unable to log in.'],
      }, 400);
    }
    return http.Response('not found', 404);
  }
}

ApiClient apiFor(FakeBackend backend) =>
    ApiClient(client: backend.client, baseUrl: 'http://test');

Widget buildApp(FakeBackend backend) => MyApp(apiClient: apiFor(backend));

/// Lets a route transition finish without letting the SnackBar time out.
Future<void> settleRoute(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

Future<void> tapCard(WidgetTester tester, String name) async {
  await tester.ensureVisible(find.text(name));
  await tester.tap(find.text(name));
  await settleRoute(tester);
}

Future<void> submitLogin(WidgetTester tester, String password) async {
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), 'owner');
  await tester.enterText(fields.at(1), password);
  await tester.tap(find.widgetWithText(ElevatedButton, 'Login'));
  await tester.pumpAndSettle();
}

void main() {
  group('ApiClient', () {
    test('getProjects parses the list and turns null URLs into ""', () async {
      final backend = FakeBackend(
        projects: [
          {
            'id': 'id-1',
            'title': 'Portfolio',
            'description': 'My site',
            'tech_stack': 'Django',
            'project_url': null,
            'project_image_url': null,
          },
        ],
      );

      final projects = await apiFor(backend).getProjects();

      expect(projects.single.title, 'Portfolio');
      expect(projects.single.techStack, 'Django');
      expect(projects.single.projectUrl, '');
      expect(projects.single.projectImageUrl, '');
    });

    test('createProject sends the token and no id in the JSON body', () async {
      final backend = FakeBackend();
      final created = await apiFor(backend).createProject(
        const Project(
          title: 'T',
          description: 'D',
          techStack: 'S',
          projectUrl: 'https://x.dev',
        ),
        token: 'abc',
      );

      final request = backend.requests.last;
      expect(request.headers['Authorization'], 'Token abc');
      final body = jsonDecode(request.body) as Map<String, dynamic>;
      expect(body['tech_stack'], 'S');
      expect(body.containsKey('id'), isFalse);
      expect(created.id, 'new-id');
    });

    test('a wrong password throws an ApiException with status 400', () async {
      await expectLater(
        apiFor(FakeBackend()).obtainToken('owner', 'wrong'),
        throwsA(
          isA<ApiException>().having((e) => e.statusCode, 'statusCode', 400),
        ),
      );
    });
  });

  group('Project list', () {
    testWidgets('shows the projects from the API without logging in', (
      tester,
    ) async {
      final backend = FakeBackend(
        projects: [
          {
            'id': 'id-1',
            'title': 'Portfolio Website',
            'description': 'My site',
            'tech_stack': 'Django',
            'project_url': '',
            'project_image_url': '',
          },
        ],
      );
      await tester.pumpWidget(buildApp(backend));
      await tapCard(tester, 'View Projects');
      await tester.pumpAndSettle();

      expect(find.byType(ProjectListScreen), findsOneWidget);
      expect(find.text('Portfolio Website'), findsOneWidget);
      expect(
        backend.requests.any((r) => r.headers.containsKey('Authorization')),
        isFalse,
      );
    });

    testWidgets('shows an empty message and an error with Retry', (
      tester,
    ) async {
      final backend = FakeBackend();
      await tester.pumpWidget(buildApp(backend));
      await tapCard(tester, 'View Projects');
      await tester.pumpAndSettle();
      expect(find.text('No projects found.'), findsOneWidget);

      // Reopen the screen while the server fails, then retry.
      await tester.binding.handlePopRoute();
      await settleRoute(tester);
      backend.failProjectList = true;
      await tapCard(tester, 'View Projects');
      await tester.pumpAndSettle();
      expect(find.textContaining('Failed to load projects'), findsOneWidget);

      backend.failProjectList = false;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.text('No projects found.'), findsOneWidget);
    });
  });

  group('Login and the protected form', () {
    testWidgets('Add Project asks for a login first, then opens the form', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp(FakeBackend()));
      await tapCard(tester, 'Add Project');
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(ProjectFormPage), findsNothing);

      await submitLogin(tester, 'secret');
      expect(find.byType(ProjectFormPage), findsOneWidget);
    });

    testWidgets('a wrong password keeps the login screen and shows a message', (
      tester,
    ) async {
      await tester.pumpWidget(buildApp(FakeBackend()));
      await tapCard(tester, 'Add Project');
      await submitLogin(tester, 'wrong');

      expect(
        find.text('Wrong username or password (HTTP 400).'),
        findsOneWidget,
      );
      expect(find.byType(LoginScreen), findsOneWidget);
      expect(find.byType(ProjectFormPage), findsNothing);
    });

    testWidgets('a valid project is posted with the token and confirmed', (
      tester,
    ) async {
      final backend = FakeBackend();
      await tester.pumpWidget(buildApp(backend));
      await tapCard(tester, 'Add Project');
      await submitLogin(tester, 'secret');
      // Let the card's SnackBar go away so it does not cover the Save button.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.at(0), 'My New Project');
      await tester.enterText(fields.at(1), 'Built with Flutter');
      await tester.enterText(fields.at(2), 'Flutter, Dart');
      await tester.enterText(fields.at(3), 'https://example.com/new');
      await tester.ensureVisible(find.text('Save'));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      final post = backend.requests.lastWhere((r) => r.method == 'POST');
      expect(post.url.path, '/api/v1/projects/');
      expect(post.headers['Authorization'], 'Token abc');
      expect(find.text('Project added successfully!'), findsOneWidget);
      expect(find.text('Title: My New Project'), findsOneWidget);
    });

    testWidgets('empty required fields are rejected without calling the API', (
      tester,
    ) async {
      final backend = FakeBackend();
      await tester.pumpWidget(buildApp(backend));
      await tapCard(tester, 'Add Project');
      await submitLogin(tester, 'secret');
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Save'));
      await tester.tap(find.text('Save'));
      await tester.pump();

      expect(find.text('Enter the title.'), findsOneWidget);
      expect(find.text('Enter the project URL.'), findsOneWidget);
      expect(find.byType(AlertDialog), findsNothing);
      expect(backend.requests.where((r) => r.method == 'POST').length, 1);
    });
  });
}
