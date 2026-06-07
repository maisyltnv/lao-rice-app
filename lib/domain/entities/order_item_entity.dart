import '../../core/utils/api_media_url.dart';
import '../../core/utils/lak_amount.dart';

class OrderItemEntity {
  const OrderItemEntity({
    required this.productId,
    required this.productName,
    required this.imageUrl,
    required this.quantity,
    required this.unitPriceLak,
    required this.lineTotalLak,
  });

  final int productId;
  final String productName;
  final String imageUrl;
  final int quantity;
  final double unitPriceLak;
  final double lineTotalLak;

  factory OrderItemEntity.fromJson(Map<String, dynamic> j) {
    final name = j['product_name'] as String? ?? '';
    return OrderItemEntity(
      productId: (j['product_id'] as num?)?.toInt() ?? 0,
      productName: name,
      imageUrl: _imageUrlFromJson(j),
      quantity: (j['quantity'] as num?)?.toInt() ?? 0,
      unitPriceLak: LakAmount.normalize(j['unit_price_lak'] as num?),
      lineTotalLak: LakAmount.normalize(j['line_total_lak'] as num?),
    );
  }

  static String _imageUrlFromJson(Map<String, dynamic> j) {
    final candidates = <String?>[];
    final product = j['product'];
    if (product is Map<String, dynamic>) {
      candidates.add(product['image_url'] as String?);
      candidates.add(product['imageUrl'] as String?);
    }
    candidates.add(j['image_url'] as String?);
    candidates.add(j['product_image_url'] as String?);

    for (final raw in candidates) {
      final resolved = ApiMediaUrl.resolve(raw);
      if (resolved.isNotEmpty &&
          !ApiMediaUrl.isPaymentReceiptMediaUrl(resolved)) {
        return resolved;
      }
    }
    return '';
  }

  /// Prefer order snapshot; fall back to live catalog [productImageUrl].
  String effectiveImageUrl({
    String? productImageUrl,
    String? orderPaymentReceiptUrl,
  }) {
    if (imageUrl.isNotEmpty &&
        !ApiMediaUrl.isPaymentReceiptMediaUrl(
          imageUrl,
          orderPaymentReceiptUrl: orderPaymentReceiptUrl,
        )) {
      return imageUrl;
    }
    final fromCatalog = productImageUrl?.trim() ?? '';
    if (fromCatalog.isNotEmpty &&
        !ApiMediaUrl.isPaymentReceiptMediaUrl(
          fromCatalog,
          orderPaymentReceiptUrl: orderPaymentReceiptUrl,
        )) {
      return fromCatalog;
    }
    return '';
  }
}
