/// Local rice images bundled in assets (API returns /images/rice/*.jpg for web).
abstract final class RiceImages {
  RiceImages._();

  static const placeholder = 'assets/images/rice/grains.jpg';
  static const _apiPrefix = '/images/rice/';
  static const _assetDir = 'assets/images/rice/';

  static const Map<String, String> byProductName = {
    'ເຂົ້ານາປີ': 'assets/images/rice/grains.jpg',
    'ເຂົ້ານາແຊງ': 'assets/images/rice/sticky.jpg',
    'ເຂົ້າໄກ່ນ້ອຍ': 'assets/images/rice/bowl.jpg',
    'ເຂົ້າຈ້າວມະລິ': 'assets/images/rice/field.jpg',
    'ເຂົ້າເຈົ້າໄຮ່': 'assets/images/rice/bag.jpg',
  };

  static const _brokenUnsplashIds = [
    '1586201375767',
    '1604329766861',
    '1536304993881',
    '1589302168068',
  ];

  static String forProduct(String name) {
    final trimmed = name.trim();
    return byProductName[trimmed] ?? placeholder;
  }

  /// Maps API/web path `/images/rice/foo.jpg` → `assets/images/rice/foo.jpg`.
  static String? assetPathFromUrl(String url) {
    final u = url.trim();
    if (u.isEmpty) return null;
    if (u.startsWith(_assetDir)) return u;
    if (u.startsWith(_apiPrefix)) {
      return '$_assetDir${u.substring(_apiPrefix.length)}';
    }
    final idx = u.indexOf(_apiPrefix);
    if (idx >= 0) {
      return '$_assetDir${u.substring(idx + _apiPrefix.length)}';
    }
    return null;
  }

  static bool isBundledAssetPath(String path) =>
      path.trim().startsWith(_assetDir);

  static bool isBrokenRemoteUrl(String url) {
    final u = url.trim().toLowerCase();
    if (u.isEmpty) return true;
    if (assetPathFromUrl(u) != null) return false;
    for (final id in _brokenUnsplashIds) {
      if (u.contains(id)) return true;
    }
    return false;
  }

  /// Prefer bundled asset for empty, relative web paths, or broken remote URLs.
  static bool shouldUseAsset(String url) {
    final u = url.trim();
    if (u.isEmpty) return true;
    if (assetPathFromUrl(u) != null) return true;
    if (isBundledAssetPath(u)) return true;
    return isBrokenRemoteUrl(u);
  }

  /// Single entry point for widgets and entity parsing.
  static String resolveAssetPath(String imageUrl, {String? productName}) {
    final fromUrl = assetPathFromUrl(imageUrl);
    if (fromUrl != null) return fromUrl;
    if (isBundledAssetPath(imageUrl)) return imageUrl.trim();
    return forProduct(productName ?? '');
  }

  /// Normalize API `image_url` when loading products.
  static String normalizeApiImageUrl(String? url, {String? productName}) {
    final raw = url?.trim() ?? '';
    if (shouldUseAsset(raw)) {
      return resolveAssetPath(raw, productName: productName);
    }
    return raw;
  }
}
