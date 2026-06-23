import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/api_config.dart';
import '../../../domain/entities/auth_user_entity.dart';
import '../../../domain/entities/banner_entity.dart';
import '../../../domain/entities/category_entity.dart';
import '../../../domain/entities/shipping_config_entity.dart';
import '../../../domain/entities/order_entity.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/entities/products_page.dart';
import '../../../domain/entities/shipping_quote_entity.dart';

/// Remote client for the Lao Rice Shop Go API.
class ApiService {
  ApiService({http.Client? httpClient}) : _client = httpClient ?? http.Client();

  final http.Client _client;

  Uri _uri(String path, [Map<String, String>? query]) {
    final base = ApiConfig.baseUrl;
    return Uri.parse('$base$path').replace(queryParameters: query);
  }

  /// [jsonContentType] adds `Content-Type: application/json` (needed for POST/PUT bodies).
  /// Avoid on simple GETs — it triggers an extra CORS preflight in the browser.
  Map<String, String> _headers({String? bearer, bool jsonContentType = false}) {
    final h = <String, String>{'Accept': 'application/json'};
    if (jsonContentType) {
      h['Content-Type'] = 'application/json';
    }
    if (bearer != null && bearer.isNotEmpty) {
      h['Authorization'] = 'Bearer $bearer';
    }
    return h;
  }

  static String? parseErrorMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final err = decoded['error'];
        if (err is String) return err;
      }
    } catch (_) {}
    return null;
  }

  Future<bool> pingHealth() async {
    try {
      final res = await _client.get(_uri('/health'));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<List<CategoryEntity>> fetchCategories({bool rootsOnly = false, int? parentId}) async {
    final query = <String, String>{};
    if (rootsOnly) query['roots_only'] = 'true';
    if (parentId != null) query['parent_id'] = '$parentId';
    final res = await _client.get(_uri('/categories', query.isEmpty ? null : query), headers: _headers());
    if (res.statusCode != 200) {
      throw ApiException(res.statusCode, res.body);
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final raw = map['items'] as List<dynamic>? ?? const [];
    return raw.map((e) => CategoryEntity.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// List products. Supports `q` (search name/description), `category_id`, pagination.
  Future<ProductsPage> fetchProducts({
    int limit = 100,
    int offset = 0,
    int? categoryId,
    String? q,
  }) async {
    final query = <String, String>{
      'limit': '$limit',
      'offset': '$offset',
    };
    if (categoryId != null) query['category_id'] = '$categoryId';
    final trimmedQ = q?.trim();
    if (trimmedQ != null && trimmedQ.isNotEmpty) {
      query['q'] = trimmedQ;
    }
    final res = await _client.get(
      _uri('/products', query),
      headers: _headers(),
    );
    if (res.statusCode != 200) {
      throw ApiException(res.statusCode, res.body);
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final raw = map['items'] as List<dynamic>? ?? const [];
    final items = raw.map((e) => ProductEntity.fromJson(e as Map<String, dynamic>)).toList();
    final total = (map['total'] as num?)?.toInt() ?? items.length;
    return ProductsPage(items: items, total: total);
  }

  /// Active homepage slides (`is_active=true`), sorted by API.
  Future<List<BannerEntity>> fetchBanners() async {
    final res = await _client.get(_uri('/banners'), headers: _headers());
    if (res.statusCode != 200) {
      throw ApiException(res.statusCode, res.body);
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final raw = map['items'] as List<dynamic>? ?? const [];
    return raw.map((e) => BannerEntity.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Single active slide by id (404 if inactive).
  Future<BannerEntity> fetchBannerById(int id) async {
    final res = await _client.get(_uri('/banners/$id'), headers: _headers());
    if (res.statusCode != 200) {
      throw ApiException(res.statusCode, res.body);
    }
    return BannerEntity.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<ProductEntity> fetchProductById(int id) async {
    final res = await _client.get(_uri('/products/$id'), headers: _headers());
    if (res.statusCode != 200) {
      throw ApiException(res.statusCode, res.body);
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    return ProductEntity.fromJson(map);
  }

  Future<void> register({
    required String username,
    required String password,
    String role = '',
  }) async {
    final body = <String, dynamic>{
      'username': username,
      'password': password,
    };
    if (role.isNotEmpty) {
      body['role'] = role;
    }
    final res = await _client.post(
      _uri('/auth/register'),
      headers: _headers(jsonContentType: true),
      body: jsonEncode(body),
    );
    if (res.statusCode != 201) {
      throw ApiException(res.statusCode, res.body);
    }
  }

  Future<({String token, String username, AuthUserEntity user})> login({
    required String username,
    required String password,
  }) async {
    final res = await _client.post(
      _uri('/auth/login'),
      headers: _headers(jsonContentType: true),
      body: jsonEncode({'username': username, 'password': password}),
    );
    if (res.statusCode != 200) {
      throw ApiException(res.statusCode, res.body);
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final token = map['access_token'] as String? ?? '';
    final userMap = map['user'] as Map<String, dynamic>? ?? const {};
    final user = AuthUserEntity.fromJson(userMap);
    final name = user.username.isNotEmpty ? user.username : username;
    return (token: token, username: name, user: user);
  }

  Future<AuthUserEntity> fetchMe(String accessToken) async {
    final res = await _client.get(
      _uri('/auth/me'),
      headers: _headers(bearer: accessToken),
    );
    if (res.statusCode != 200) {
      throw ApiException(res.statusCode, res.body);
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    return AuthUserEntity.fromJson(map);
  }

  /// Permanently deletes the signed-in user's account (DELETE /auth/me).
  Future<void> deleteAccount(String accessToken) async {
    final res = await _client.delete(
      _uri('/auth/me'),
      headers: _headers(bearer: accessToken),
    );
    if (res.statusCode != 200 && res.statusCode != 204) {
      throw ApiException(res.statusCode, res.body);
    }
  }

  Future<AuthUserEntity> updateCustomerProfile({
    required String accessToken,
    required String recipientName,
    required String shippingPhone,
    required String addressDetail,
    String province = 'ນະຄອນຫຼວງວຽງຈັນ',
    required double deliveryLatitude,
    required double deliveryLongitude,
  }) async {
    final payload = jsonEncode({
      'recipient_name': recipientName,
      'shipping_phone': shippingPhone,
      'province': province,
      'address_detail': addressDetail,
      'delivery_latitude': deliveryLatitude,
      'delivery_longitude': deliveryLongitude,
    });
    final headers = _headers(bearer: accessToken, jsonContentType: true);
    var res = await _client.put(
      _uri('/auth/me/profile'),
      headers: headers,
      body: payload,
    );
    if (res.statusCode == 404) {
      res = await _client.post(
        _uri('/auth/me/profile'),
        headers: headers,
        body: payload,
      );
    }
    if (res.statusCode != 200) {
      if (res.statusCode == 404) {
        throw ApiException(
          res.statusCode,
          'API ຍັງບໍ່ມີຟັງຊັນບັນທຶກທີ່ຢູ່ — deploy lao-rice-api ລ່າສຸດ (docker compose up -d --build)',
        );
      }
      throw ApiException(res.statusCode, res.body);
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    return AuthUserEntity.fromJson(map);
  }

  Future<void> sendPhoneOtp(String phone) async {
    final res = await _client.post(
      _uri('/auth/otp/send'),
      headers: _headers(jsonContentType: true),
      body: jsonEncode({'phone': phone}),
    );
    if (res.statusCode != 200) {
      throw ApiException(res.statusCode, res.body);
    }
  }

  Future<({String token, String username, AuthUserEntity user})> verifyPhoneOtp({
    required String phone,
    required String code,
  }) async {
    final res = await _client.post(
      _uri('/auth/otp/verify'),
      headers: _headers(jsonContentType: true),
      body: jsonEncode({'phone': phone, 'code': code}),
    );
    if (res.statusCode != 200) {
      throw ApiException(res.statusCode, res.body);
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final token = map['access_token'] as String? ?? '';
    final userMap = map['user'] as Map<String, dynamic>? ?? const {};
    final user = AuthUserEntity.fromJson(userMap);
    final name = user.username.isNotEmpty ? user.username : phone;
    return (token: token, username: name, user: user);
  }

  Future<ProductEntity> createProduct(
    String accessToken, {
    required String name,
    required double originalPriceCny,
    required double exchangeRate,
    required double profitMargin,
    String description = '',
    String imageUrl = '',
    String category = '',
    double? finalPriceLak,
    String sourceUrl = '',
  }) async {
    final body = <String, dynamic>{
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'category': category,
      'original_price_cny': originalPriceCny,
      'exchange_rate': exchangeRate,
      'profit_margin': profitMargin,
      'source_url': sourceUrl,
    };
    if (finalPriceLak != null) {
      body['final_price_lak'] = finalPriceLak;
    }
    final res = await _client.post(
      _uri('/products'),
      headers: _headers(bearer: accessToken, jsonContentType: true),
      body: jsonEncode(body),
    );
    if (res.statusCode != 201) {
      throw ApiException(res.statusCode, res.body);
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    return ProductEntity.fromJson(map);
  }

  Future<ProductEntity> updateProduct(
    String accessToken,
    int id, {
    String? name,
    String? description,
    String? imageUrl,
    String? category,
    double? originalPriceCny,
    double? exchangeRate,
    double? profitMargin,
    double? finalPriceLak,
    String? sourceUrl,
  }) async {
    final body = <String, dynamic>{};
    if (name != null) body['name'] = name;
    if (description != null) body['description'] = description;
    if (imageUrl != null) body['image_url'] = imageUrl;
    if (category != null) body['category'] = category;
    if (originalPriceCny != null) body['original_price_cny'] = originalPriceCny;
    if (exchangeRate != null) body['exchange_rate'] = exchangeRate;
    if (profitMargin != null) body['profit_margin'] = profitMargin;
    if (finalPriceLak != null) body['final_price_lak'] = finalPriceLak;
    if (sourceUrl != null) body['source_url'] = sourceUrl;

    final res = await _client.put(
      _uri('/products/$id'),
      headers: _headers(bearer: accessToken, jsonContentType: true),
      body: jsonEncode(body),
    );
    if (res.statusCode != 200) {
      throw ApiException(res.statusCode, res.body);
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    return ProductEntity.fromJson(map);
  }

  Future<void> deleteProduct(String accessToken, int id) async {
    final res = await _client.delete(
      _uri('/products/$id'),
      headers: _headers(bearer: accessToken),
    );
    if (res.statusCode != 204 && res.statusCode != 200) {
      throw ApiException(res.statusCode, res.body);
    }
  }

  Future<({List<OrderEntity> items, int page, int totalPages, bool hasNext})> fetchMyOrders({
    required String accessToken,
    int page = 1,
    int limit = 10,
  }) async {
    final res = await _client.get(
      _uri('/orders/mine', {'page': '$page', 'limit': '$limit'}),
      headers: _headers(bearer: accessToken),
    );
    if (res.statusCode == 401) {
      throw ApiException(res.statusCode, res.body);
    }
    if (res.statusCode != 200) {
      throw ApiException(res.statusCode, res.body);
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final raw = map['items'] as List<dynamic>? ?? const [];
    return (
      items: raw.map((e) => OrderEntity.fromJson(e as Map<String, dynamic>)).toList(),
      page: (map['page'] as num?)?.toInt() ?? 1,
      totalPages: (map['total_pages'] as num?)?.toInt() ?? 1,
      hasNext: map['has_next'] as bool? ?? false,
    );
  }

  Future<ShippingConfigEntity> fetchShippingConfig() async {
    final res = await _client.get(_uri('/orders/shipping-config'), headers: _headers());
    if (res.statusCode != 200) {
      throw ApiException(res.statusCode, res.body);
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    return ShippingConfigEntity.fromJson(map);
  }

  Future<ShippingQuoteEntity> fetchShippingQuote(double subtotalLak) async {
    final res = await _client.get(
      _uri('/orders/shipping-quote', {'subtotal_lak': subtotalLak.toStringAsFixed(0)}),
      headers: _headers(),
    );
    if (res.statusCode != 200) {
      throw ApiException(res.statusCode, res.body);
    }
    return ShippingQuoteEntity.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<({List<OrderEntity> items, int page, int totalPages, bool hasNext})> fetchOrdersByPhone({
    required String phone,
    int page = 1,
    int limit = 10,
  }) async {
    final res = await _client.get(
      _uri('/ordersbyphone', {'phone': phone, 'page': '$page', 'limit': '$limit'}),
      headers: _headers(),
    );
    if (res.statusCode != 200) {
      throw ApiException(res.statusCode, res.body);
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    final raw = map['items'] as List<dynamic>? ?? const [];
    return (
      items: raw.map((e) => OrderEntity.fromJson(e as Map<String, dynamic>)).toList(),
      page: (map['page'] as num?)?.toInt() ?? 1,
      totalPages: (map['total_pages'] as num?)?.toInt() ?? 1,
      hasNext: map['has_next'] as bool? ?? false,
    );
  }

  /// Authenticated `POST /orders`. Sends multipart when [paymentReceiptBytes] is set (BCEL QR).
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
  }) async {
    final itemsJson = items.map((e) => {'product_id': e.productId, 'quantity': e.quantity}).toList();
    final shippingJson = {
      'recipient_name': recipientName,
      'phone': phone,
      'address_detail': addressDetail,
      'latitude': latitude,
      'longitude': longitude,
    };

    if (paymentReceiptBytes != null && paymentReceiptBytes.isNotEmpty) {
      final request = http.MultipartRequest('POST', _uri('/orders'));
      request.headers['Accept'] = 'application/json';
      request.headers['Authorization'] = 'Bearer $accessToken';
      request.fields['payment_method'] = paymentMethod;
      request.fields['items'] = jsonEncode(itemsJson);
      request.fields['shipping'] = jsonEncode(shippingJson);
      request.files.add(
        http.MultipartFile.fromBytes(
          'payment_receipt',
          paymentReceiptBytes,
          filename: paymentReceiptFilename ?? 'receipt.jpg',
        ),
      );
      final streamed = await request.send();
      final res = await http.Response.fromStream(streamed);
      if (res.statusCode != 201) {
        throw ApiException(res.statusCode, res.body);
      }
      final map = jsonDecode(res.body) as Map<String, dynamic>;
      return OrderEntity.fromJson(map);
    }

    final res = await _client.post(
      _uri('/orders'),
      headers: _headers(bearer: accessToken, jsonContentType: true),
      body: jsonEncode({
        'payment_method': paymentMethod,
        'items': itemsJson,
        'shipping': shippingJson,
      }),
    );
    if (res.statusCode != 201) {
      throw ApiException(res.statusCode, res.body);
    }
    final map = jsonDecode(res.body) as Map<String, dynamic>;
    return OrderEntity.fromJson(map);
  }
}

class ApiException implements Exception {
  ApiException(this.statusCode, this.body);
  final int statusCode;
  final String body;

  String get messageOrBody => ApiService.parseErrorMessage(body) ?? body;

  @override
  String toString() => 'ApiException($statusCode): $messageOrBody';
}
