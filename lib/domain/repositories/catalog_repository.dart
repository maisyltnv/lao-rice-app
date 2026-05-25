import '../entities/category_entity.dart';
import '../entities/product_entity.dart';
import '../entities/products_page.dart';

abstract class CatalogRepository {
  Future<List<CategoryEntity>> fetchCategories();

  Future<ProductsPage> fetchProducts({
    int limit = 100,
    int offset = 0,
    int? categoryId,
    String? q,
  });

  Future<ProductEntity> fetchProductById(int id);
}
