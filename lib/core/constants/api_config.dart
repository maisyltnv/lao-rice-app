import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Base URL for the Lao Rice Go API (default port 8081 when using lao-rice-api docker-compose).
///
/// - **Web**: `127.0.0.1` (IPv4) — on Windows, `localhost` in the browser often resolves to
///   IPv6 (`::1`) while a local Go server may listen on IPv4 only, which surfaces as
///   `ClientException: Failed to fetch`.
/// - **iOS simulator / desktop (non-web)**: `localhost`.
/// - **Android emulator**: `10.0.2.2` maps to the host machine loopback.
/// - **Physical device**: pass `--dart-define=API_BASE=http://<your-lan-ip>:8080`
///
/// Do not use `dart:io` [Platform] here — it throws on web (`Platform._operatingSystem`).
class ApiConfig {
  ApiConfig._();

  static const int port = 8081;

  static String get baseUrl {
    const override = String.fromEnvironment('API_BASE');
    if (override.isNotEmpty) return override;
    if (kIsWeb) {
      return 'http://127.0.0.1:$port';
    }
    final host = defaultTargetPlatform == TargetPlatform.android ? '10.0.2.2' : 'localhost';
    return 'http://$host:$port';
  }
}
