import '../../domain/entities/banner_entity.dart';

/// Parses banner [BannerEntity.linkUrl] for navigation hints.
sealed class BannerLinkAction {}

class BannerLinkShowAll extends BannerLinkAction {}

class BannerLinkCategory extends BannerLinkAction {
  BannerLinkCategory(this.categoryId);
  final int categoryId;
}

class BannerLinkProduct extends BannerLinkAction {
  BannerLinkProduct(this.productId);
  final int productId;
}

BannerLinkAction parseBannerLink(String linkUrl) {
  final link = linkUrl.trim();
  if (link.isEmpty) return BannerLinkShowAll();

  final productMatch = RegExp(r'/products/(\d+)').firstMatch(link);
  if (productMatch != null) {
    return BannerLinkProduct(int.parse(productMatch.group(1)!));
  }

  final catMatch = RegExp(r'category_id=(\d+)').firstMatch(link);
  if (catMatch != null) {
    return BannerLinkCategory(int.parse(catMatch.group(1)!));
  }

  return BannerLinkShowAll();
}
