import 'product_entity.dart';

class CartItemEntity {
  CartItemEntity({required this.product, this.quantity = 1});

  final ProductEntity product;
  int quantity;

  double get lineTotalLak => product.finalPriceLak * quantity;
}
