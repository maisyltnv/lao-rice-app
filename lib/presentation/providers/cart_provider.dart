import 'package:flutter/foundation.dart';

import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/product_entity.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItemEntity> _items = [];

  List<CartItemEntity> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, e) => sum + e.quantity);

  double get subtotalLak => _items.fold(0, (sum, e) => sum + e.lineTotalLak);

  bool get isEmpty => _items.isEmpty;

  void add(ProductEntity product, {int quantity = 1}) {
    final existing = _items.where((e) => e.product.id == product.id).firstOrNull;
    if (existing != null) {
      existing.quantity += quantity;
    } else {
      _items.add(CartItemEntity(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  void setQuantity(int productId, int quantity) {
    final item = _items.where((e) => e.product.id == productId).firstOrNull;
    if (item == null) return;
    if (quantity <= 0) {
      _items.remove(item);
    } else {
      item.quantity = quantity;
    }
    notifyListeners();
  }

  void remove(int productId) {
    _items.removeWhere((e) => e.product.id == productId);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}
