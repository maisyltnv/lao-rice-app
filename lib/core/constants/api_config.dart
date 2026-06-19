/// Base URL for the Lao Rice API.
///
/// Default: production (`https://api.khaosan.online`).
///
/// Local dev override:
/// ```bash
/// flutter run --dart-define=API_BASE=http://127.0.0.1:8081
/// # Android emulator:
/// flutter run --dart-define=API_BASE=http://10.0.2.2:8081
/// # Physical phone on same Wi‑Fi as your Mac:
/// flutter run --dart-define=API_BASE=http://192.168.x.x:8081
/// ```
library;

import 'package:flutter/foundation.dart';

class ApiConfig {
  ApiConfig._();

  static const int port = 8081;

  /// Production API (same host as lao-rice-web `.env.production`).
  static const String productionBaseUrl = 'https://api.khaosan.online';

  static String get baseUrl {
    const override = String.fromEnvironment('API_BASE');
    if (override.isNotEmpty) return override;
    // Developer-friendly default:
    // - Debug builds default to local API
    // - Release builds default to production API
    //
    // NOTE: Android emulator cannot reach host localhost; it must use 10.0.2.2.
    // For real devices, pass --dart-define=API_BASE=http://<your-lan-ip>:8081.
    return kDebugMode ? debugDefaultBaseUrl : productionBaseUrl;
  }

  static String get debugDefaultBaseUrl {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:$port';
    }
    return 'http://127.0.0.1:$port';
  }
}
