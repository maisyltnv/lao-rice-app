import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/checkout_error_message.dart';
import '../../data/datasources/remote/api_service.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/shipping_config_entity.dart';
import '../../domain/entities/shipping_quote_entity.dart';
import '../../domain/repositories/orders_repository.dart';

class OrdersProvider extends ChangeNotifier {
  OrdersProvider(this._repository);

  final OrdersRepository _repository;

  static const _kSavedPhone = 'customer_phone';

  List<OrderEntity> _orders = const [];
  bool _loading = false;
  String? _error;
  String? _phone;
  int _page = 1;
  bool _hasNext = false;
  ShippingQuoteEntity? _shippingQuote;
  ShippingConfigEntity? _shippingConfig;

  List<OrderEntity> get orders => _orders;
  bool get isLoading => _loading;
  String? get error => _error;
  String? get phone => _phone;
  bool get hasNext => _hasNext;
  ShippingQuoteEntity? get shippingQuote => _shippingQuote;
  ShippingConfigEntity? get shippingConfig => _shippingConfig;
  bool get codEnabled => _shippingConfig?.codEnabled ?? true;
  bool get bcelQrEnabled => _shippingConfig?.bcelQrEnabled ?? true;

  Future<void> loadSavedPhone() async {
    final prefs = await SharedPreferences.getInstance();
    _phone = prefs.getString(_kSavedPhone);
    notifyListeners();
  }

  Future<void> savePhone(String phone) async {
    _phone = phone.trim();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kSavedPhone, _phone!);
    notifyListeners();
  }

  Future<void> loadMyOrders({
    required String accessToken,
    bool refresh = true,
  }) async {
    if (refresh) {
      _page = 1;
      _orders = const [];
    }
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _repository.fetchMyOrders(
        accessToken: accessToken,
        page: _page,
        limit: 10,
      );
      _orders = refresh ? result.items : [..._orders, ...result.items];
      _hasNext = result.hasNext;
      _error = null;
    } catch (e) {
      _error = e is ApiException ? e.messageOrBody : e.toString();
      if (refresh) _orders = const [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreMyOrders(String accessToken) async {
    if (!_hasNext || _loading) return;
    _page += 1;
    await loadMyOrders(accessToken: accessToken, refresh: false);
  }

  Future<void> searchByPhone(String phone, {bool refresh = true}) async {
    final trimmed = phone.trim();
    if (trimmed.isEmpty) return;
    _phone = trimmed;
    await savePhone(trimmed);
    if (refresh) {
      _page = 1;
      _orders = const [];
    }
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _repository.fetchOrdersByPhone(phone: trimmed, page: _page, limit: 10);
      _orders = refresh ? result.items : [..._orders, ...result.items];
      _hasNext = result.hasNext;
      _error = null;
    } catch (e) {
      _error = e is ApiException ? e.messageOrBody : e.toString();
      if (refresh) _orders = const [];
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_phone == null || !_hasNext || _loading) return;
    _page += 1;
    await searchByPhone(_phone!, refresh: false);
  }

  Future<ShippingQuoteEntity?> refreshShippingQuote(double subtotalLak) async {
    try {
      _shippingQuote = await _repository.fetchShippingQuote(subtotalLak);
      notifyListeners();
      return _shippingQuote;
    } catch (_) {
      return null;
    }
  }

  Future<ShippingConfigEntity?> refreshShippingConfig() async {
    try {
      _shippingConfig = await _repository.fetchShippingConfig();
      notifyListeners();
      return _shippingConfig;
    } catch (_) {
      return null;
    }
  }

  Future<OrderEntity?> checkout({
    required String accessToken,
    required List<CartItemEntity> cartItems,
    required String recipientName,
    required String phone,
    required String addressDetail,
    required double latitude,
    required double longitude,
    required String paymentMethod,
    List<int>? paymentReceiptBytes,
    String? paymentReceiptFilename,
  }) async {
    if (cartItems.isEmpty) return null;
    _error = null;
    notifyListeners();
    try {
      final created = await _repository.placeOrder(
        accessToken: accessToken,
        paymentMethod: paymentMethod,
        items: cartItems
            .map((e) => (productId: e.product.id, quantity: e.quantity))
            .toList(),
        recipientName: recipientName,
        phone: phone,
        addressDetail: addressDetail,
        latitude: latitude,
        longitude: longitude,
        paymentReceiptBytes: paymentReceiptBytes,
        paymentReceiptFilename: paymentReceiptFilename,
      );
      await savePhone(phone);
      _orders = [created, ..._orders];
      notifyListeners();
      return created;
    } catch (e) {
      final raw = e is ApiException ? e.messageOrBody : e.toString();
      _error = friendlyCheckoutError(raw);
      notifyListeners();
      return null;
    }
  }
}
