import '../../core/utils/api_media_url.dart';
import '../../core/utils/lak_amount.dart';

class ProductEntity {
  const ProductEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.imageUrls,
    required this.category,
    required this.categoryId,
    required this.finalPriceLak,
    required this.sourceUrl,
  });

  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final List<String> imageUrls;
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
    final parsedUrls = <String>[];
    final rawUrls = j['image_urls'];
    if (rawUrls is List) {
      for (final item in rawUrls) {
        final url = _imageUrlFromApi(item?.toString());
        if (url.isNotEmpty && !parsedUrls.contains(url)) {
          parsedUrls.add(url);
        }
      }
    }
    final cover = _imageUrlFromApi(j['image_url'] as String?);
    if (parsedUrls.isEmpty && cover.isNotEmpty) {
      parsedUrls.add(cover);
    }
    return ProductEntity(
      id: (j['id'] as num).toInt(),
      name: name,
      description: j['description'] as String? ?? '',
      imageUrl: parsedUrls.isNotEmpty ? parsedUrls.first : cover,
      imageUrls: parsedUrls,
      category: categoryName,
      categoryId: categoryId,
      finalPriceLak: LakAmount.normalize(j['final_price_lak'] as num?),
      sourceUrl: j['source_url'] as String? ?? '',
    );
  }

  static String _imageUrlFromApi(String? url) {
    return ApiMediaUrl.resolve(url);
  }
}
