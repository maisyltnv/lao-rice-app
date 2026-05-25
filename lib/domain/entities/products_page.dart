import 'product_entity.dart';

/// Response from `GET /products` (`items` + `total`).
class ProductsPage {
  const ProductsPage({required this.items, required this.total});

  final List<ProductEntity> items;
  final int total;
}
