/// Base URL of the Django REST Framework backend.
///
/// Defaults to `http://10.0.2.2:8000` (the host PC as seen from the Android
/// emulator). Override it for other targets, for example for Chrome:
/// `--dart-define=API_BASE_URL=http://localhost:8000`
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://10.0.2.2:8000',
);
