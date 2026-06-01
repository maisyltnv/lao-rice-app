/// Base URL for the Lao Rice API.
///
/// Default: production VPS (`http://62.171.159.75:8081`).
///
/// Local dev override:
/// ```bash
/// flutter run --dart-define=API_BASE=http://127.0.0.1:8081
/// # Android emulator:
/// flutter run --dart-define=API_BASE=http://10.0.2.2:8081
/// # Physical phone on same Wi‑Fi as your Mac:
/// flutter run --dart-define=API_BASE=http://192.168.x.x:8081
/// ```
class ApiConfig {
  ApiConfig._();

  static const int port = 8081;

  /// Production API (same host as lao-rice-web `.env.production`).
  static const String productionBaseUrl = 'http://62.171.159.75:$port';

  static String get baseUrl {
    const override = String.fromEnvironment('API_BASE');
    if (override.isNotEmpty) return override;
    return productionBaseUrl;
  }
}
