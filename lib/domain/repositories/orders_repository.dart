import '../entities/order_entity.dart';
import '../entities/shipping_quote_entity.dart';

abstract class OrdersRepository {
  Future<({List<OrderEntity> items, int page, int totalPages, bool hasNext})> fetchOrdersByPhone({
    required String phone,
    int page = 1,
    int limit = 10,
  });

  Future<ShippingQuoteEntity> fetchShippingQuote(double subtotalLak);

  Future<({double shippingFeeLak, double freeShippingMinSubtotalLak})> fetchShippingConfig();

  /// Public checkout — [paymentReceiptBytes] required when [paymentMethod] is `bcel_qr`.
  Future<OrderEntity> placeOrder({
    required String paymentMethod,
    required List<({int productId, int quantity})> items,
    required String recipientName,
    required String phone,
    required String addressDetail,
    required double latitude,
    required double longitude,
    List<int>? paymentReceiptBytes,
    String? paymentReceiptFilename,
  });
}
