import '../constants/api_config.dart';

/// Resolves media paths from the Lao Rice API the same way as the web client.
///
/// Relative paths such as `/images/rice/foo.jpg` or `/uploads/receipt.jpg` are
/// prefixed with [ApiConfig.baseUrl]. Absolute `http(s)://` URLs are unchanged.
abstract final class ApiMediaUrl {
  ApiMediaUrl._();

  static String resolve(String? url) {
    final trimmed = url?.trim() ?? '';
    if (trimmed.isEmpty) return '';
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }
    if (trimmed.startsWith('assets/')) return trimmed;
    final base = ApiConfig.baseUrl.replaceAll(RegExp(r'/+$'), '');
    final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return '$base$path';
  }
}
