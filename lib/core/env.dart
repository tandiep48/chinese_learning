/// Core — runtime environment configuration.
///
/// Holds the backend base URL for the learner API (the Flask app in
/// `Learning/web_app`, run locally during development). The host differs by
/// platform because "localhost" means the device/emulator itself:
///   • Android emulator  → 10.0.2.2 is the host loopback alias.
///   • iOS simulator     → localhost reaches the host directly.
///
/// Run the backend first:  (in Learning/web_app)  `python app.py`  (port 5000).
/// Override at build time with:  `--dart-define=API_BASE_URL=http://host:port`
library;

import 'dart:io' show Platform;

class Env {
  const Env._();

  /// Explicit override wins (physical device on a LAN, staging, etc.).
  static const String _override = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: '',
  );

  static const int _port = 5000;

  /// Base URL of the backend API, without a trailing slash.
  static String get apiBaseUrl {
    if (_override.isNotEmpty) return _override;
    final host = Platform.isAndroid ? '10.0.2.2' : 'localhost';
    return 'http://$host:$_port';
  }
}
