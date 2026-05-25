import '../../core/constants/rice_images.dart';

class ProductEntity {
  const ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.categoryId,
    required this.finalPriceLak,
    required this.sourceUrl,
  });

  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final int? categoryId;
  final double finalPriceLak;
  final String sourceUrl;

  factory ProductEntity.fromJson(Map<String, dynamic> j) {
    String categoryName = '';
    int? categoryId = (j['category_id'] as num?)?.toInt();
    final nested = j['category'];
    if (nested is Map<String, dynamic>) {
      categoryName = nested['name'] as String? ?? '';
      categoryId ??= (nested['id'] as num?)?.toInt();
    }
    final cat = (j['category'] is String ? j['category'] as String? : null)?.trim();
    if (cat != null && cat.isNotEmpty) {
      categoryName = cat;
    }
    if (categoryName.isEmpty) {
      categoryName = 'ທົ່ວໄປ';
    }
    final name = j['name'] as String? ?? '';
    return ProductEntity(
      id: (j['id'] as num).toInt(),
      name: name,
      description: j['description'] as String? ?? '',
      imageUrl: RiceImages.normalizeApiImageUrl(
        j['image_url'] as String?,
        productName: name,
      ),
      category: categoryName,
      categoryId: categoryId,
      finalPriceLak: (j['final_price_lak'] as num?)?.toDouble() ?? 0,
      sourceUrl: j['source_url'] as String? ?? '',
    );
  }
}
