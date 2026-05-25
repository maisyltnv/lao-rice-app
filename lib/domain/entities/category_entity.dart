class CategoryEntity {
  const CategoryEntity({
    required this.id,
    required this.name,
    required this.slug,
    this.parentId,
  });

  final int id;
  final String name;
  final String slug;
  final int? parentId;

  factory CategoryEntity.fromJson(Map<String, dynamic> j) {
    return CategoryEntity(
      id: (j['id'] as num).toInt(),
      name: j['name'] as String? ?? '',
      slug: j['slug'] as String? ?? '',
      parentId: (j['parent_id'] as num?)?.toInt(),
    );
  }
}
