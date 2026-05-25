class BannerEntity {
  const BannerEntity({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imageUrl,
    required this.ctaLabel,
    required this.linkUrl,
    required this.sortOrder,
    required this.isActive,
  });

  final int id;
  final String title;
  final String subtitle;
  final String description;
  final String imageUrl;
  final String ctaLabel;
  final String linkUrl;
  final int sortOrder;
  final bool isActive;

  String get displayBadge => subtitle.trim().isNotEmpty ? subtitle.trim() : 'ໂປຣໂມຊັ່ນ';

  String get displaySubtitle {
    final d = description.trim();
    if (d.isNotEmpty) return d;
    return subtitle.trim();
  }

  String get displayCta => ctaLabel.trim().isNotEmpty ? ctaLabel.trim() : 'ຊື້ເລີຍ';

  factory BannerEntity.fromJson(Map<String, dynamic> j) {
    return BannerEntity(
      id: (j['id'] as num).toInt(),
      title: j['title'] as String? ?? '',
      subtitle: j['subtitle'] as String? ?? '',
      description: j['description'] as String? ?? '',
      imageUrl: j['image_url'] as String? ?? '',
      ctaLabel: j['cta_label'] as String? ?? '',
      linkUrl: j['link_url'] as String? ?? '',
      sortOrder: (j['sort_order'] as num?)?.toInt() ?? 0,
      isActive: j['is_active'] as bool? ?? true,
    );
  }
}
