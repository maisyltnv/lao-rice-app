import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_media_url.dart';

/// Resolves product image URLs to a direct image file URL when possible.
///
/// Some products store Kommodo *share page* links (`kommodo.ai/i/...`) instead of
/// a `.png`/`.jpg` URL. [Image.network] cannot render HTML, so we fetch `og:image`.
class ProductImageUrlResolver {
  ProductImageUrlResolver({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static final Map<String, String> _cache = {};
  static const _userAgent =
      'Mozilla/5.0 (compatible; LaoRiceShop/1.0; +https://kommodo.ai)';

  static final ProductImageUrlResolver shared = ProductImageUrlResolver();

  /// Returns a previously resolved direct image URL, if any.
  static String? cachedDirectUrl(String url) {
    final cached = _cache[url.trim()];
    if (cached != null && isDirectImageUrl(cached)) return cached;
    return null;
  }

  static bool isDirectImageUrl(String url) {
    if (url.isEmpty) return false;
    final trimmed = url.trim();
    // Relative API paths are resolved to absolute URLs before [Image.network].
    if (trimmed.startsWith('/')) return false;
    final lower = trimmed.toLowerCase();
    if (lower.contains('images.unsplash.com')) return true;
    if (lower.contains('/image/upload')) return true;
    if (RegExp(r'\.(png|jpe?g|webp|gif)(\?|$)', caseSensitive: false).hasMatch(lower)) {
      return true;
    }
    if (lower.contains('plain-apac-prod-public.komododecks.com')) return true;
    if (ApiMediaUrl.isApiHostedImage(trimmed)) return true;
    return false;
  }

  Future<String> resolve(String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return trimmed;
    if (isDirectImageUrl(trimmed)) return trimmed;

    final cached = _cache[trimmed];
    if (cached != null) return cached;

    if (trimmed.contains('kommodo.ai/i/')) {
      final direct = await _resolveKommodoSharePage(trimmed);
      if (isDirectImageUrl(direct)) {
        _cache[trimmed] = direct;
      }
      return direct;
    }

    return trimmed;
  }

  Future<String> _resolveKommodoSharePage(String pageUrl) async {
    try {
      final res = await _client
          .get(
            Uri.parse(pageUrl),
            headers: const {'User-Agent': _userAgent, 'Accept': 'text/html'},
          )
          .timeout(const Duration(seconds: 20));
      if (res.statusCode != 200) return pageUrl;

      final body = utf8.decode(res.bodyBytes, allowMalformed: true);
      final og = RegExp(
        r'<meta[^>]+property=["'']og:image["''][^>]+content=["'']([^"'']+)["'']',
        caseSensitive: false,
      ).firstMatch(body);
      if (og != null) {
        final direct = og.group(1)!.trim();
        if (direct.isNotEmpty && isDirectImageUrl(direct)) return direct;
      }

      final ogAlt = RegExp(
        r'<meta[^>]+content=["'']([^"'']+)["''][^>]+property=["'']og:image["'']',
        caseSensitive: false,
      ).firstMatch(body);
      if (ogAlt != null) {
        final direct = ogAlt.group(1)!.trim();
        if (direct.isNotEmpty && isDirectImageUrl(direct)) return direct;
      }

      final cdn = RegExp(
        r'https://plain-apac-prod-public\.komododecks\.com/[^"\s]+\.(?:png|jpe?g|webp)',
        caseSensitive: false,
      ).firstMatch(body);
      if (cdn != null) return cdn.group(0)!;
    } catch (_) {}

    return pageUrl;
  }
}
