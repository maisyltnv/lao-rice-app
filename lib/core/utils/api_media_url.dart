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
    final base = _baseWithoutTrailingSlash;
    final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';
    return '$base$path';
  }

  static String get _baseWithoutTrailingSlash =>
      ApiConfig.baseUrl.replaceAll(RegExp(r'/+$'), '');

  static bool hasImageFileExtension(String url) {
    return RegExp(
      r'\.(png|jpe?g|webp|gif|bmp|heic|heif)(\?|#|$)',
      caseSensitive: false,
    ).hasMatch(url);
  }

  /// Product/banner files on this API (`/images/...` or `/uploads/photo.jpg`).
  static bool isApiHostedImage(String url) {
    final resolved = resolve(url);
    if (resolved.isEmpty) return false;
    final lower = resolved.toLowerCase();
    final base = _baseWithoutTrailingSlash.toLowerCase();
    if (!lower.startsWith(base)) return false;
    final path = lower.substring(base.length);
    if (path.startsWith('/images/')) return true;
    if (path.startsWith('/uploads/')) {
      if (hasImageFileExtension(path)) return true;
      final name = path.substring('/uploads/'.length);
      if (name.isNotEmpty &&
          !name.contains('receipt') &&
          !name.contains('payment')) {
        return true;
      }
    }
    return false;
  }

  /// Order payment slip only — not product images stored under `/uploads/`.
  static bool isPaymentReceiptMediaUrl(
    String url, {
    String? orderPaymentReceiptUrl,
  }) {
    final resolved = resolve(url);
    if (resolved.isEmpty) return false;
    final lower = resolved.toLowerCase();
    if (lower.contains('payment_receipt')) return true;
    final receipt = resolve(orderPaymentReceiptUrl);
    if (receipt.isNotEmpty && resolved == receipt) return true;
    return false;
  }
}
