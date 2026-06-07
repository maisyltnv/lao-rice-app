import '../../domain/entities/shipping_config_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/shipping_quote_entity.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/remote/api_service.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  OrdersRepositoryImpl(this._api);

  final ApiService _api;

  @override
  Future<({List<OrderEntity> items, int page, int totalPages, bool hasNext})> fetchOrdersByPhone({
    required String phone,
    int page = 1,
    int limit = 10,
  }) {
    return _api.fetchOrdersByPhone(phone: phone, page: page, limit: limit);
  }

  @override
  Future<({List<OrderEntity> items, int page, int totalPages, bool hasNext})> fetchMyOrders({
    required String accessToken,
    int page = 1,
    int limit = 10,
  }) {
    return _api.fetchMyOrders(accessToken: accessToken, page: page, limit: limit);
  }

  @override
  Future<ShippingQuoteEntity> fetchShippingQuote(double subtotalLak) {
    return _api.fetchShippingQuote(subtotalLak);
  }

  @override
  Future<ShippingConfigEntity> fetchShippingConfig() {
    return _api.fetchShippingConfig();
  }

  @override
  Future<OrderEntity> placeOrder({
    required String accessToken,
    required String paymentMethod,
    required List<({int productId, int quantity})> items,
    required String recipientName,
    required String phone,
    required String addressDetail,
    required double latitude,
    required double longitude,
    List<int>? paymentReceiptBytes,
    String? paymentReceiptFilename,
  }) {
    return _api.placeOrder(
      accessToken: accessToken,
      paymentMethod: paymentMethod,
      items: items,
      recipientName: recipientName,
      phone: phone,
      addressDetail: addressDetail,
      latitude: latitude,
      longitude: longitude,
      paymentReceiptBytes: paymentReceiptBytes,
      paymentReceiptFilename: paymentReceiptFilename,
    );
  }
}
