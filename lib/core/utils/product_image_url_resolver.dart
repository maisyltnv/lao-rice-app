import 'dart:convert';

import 'package:http/http.dart' as http;

/// Resolves product image URLs to a direct image file URL when possible.
///
/// Some products store Kommodo *share page* links (`kommodo.ai/i/...`) instead of
/// a `.png`/`.jpg` URL. [Image.network] cannot render HTML, so we fetch `og:image`.
class ProductImageUrlResolver {
  ProductImageUrlResolver({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static final Map<String, String> _cache = {};

  static final ProductImageUrlResolver shared = ProductImageUrlResolver();

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
      _cache[trimmed] = direct;
      return direct;
    }

    return trimmed;
  }

  Future<String> _resolveKommodoSharePage(String pageUrl) async {
    try {
      final res = await _client.get(Uri.parse(pageUrl)).timeout(const Duration(seconds: 12));
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
