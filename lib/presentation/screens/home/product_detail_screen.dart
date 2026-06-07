import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../domain/entities/product_entity.dart';
import '../../providers/cart_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../widgets/price_tag.dart';
import '../../widgets/product_image.dart';
import '../../widgets/top_right_toast.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.initial,
  });

  final int productId;
  final ProductEntity? initial;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  ProductEntity? _product;
  bool _loading = true;
  String? _loadError;
  int _selectedImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _product = widget.initial;
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    final catalog = context.read<CatalogProvider>();
    final p = await catalog.fetchProductById(widget.productId);
    if (!mounted) return;
    if (p != null) {
      setState(() {
        _product = p;
        _selectedImageIndex = 0;
        _loading = false;
      });
    } else {
      setState(() {
        _loading = false;
        _loadError = 'ໂຫຼດສິນຄ້າບໍ່ສຳເລັດ';
      });
    }
  }

  void _addToCart() {
    final product = _product;
    if (product == null) return;
    context.read<CartProvider>().add(product);
    showTopRightToast(context, 'ເພີ່ມໃສ່ກະຕ່າແລ້ວ');
  }

  List<String> get _gallery {
    final product = _product;
    if (product == null) return const [];
    if (product.imageUrls.isNotEmpty) return product.imageUrls;
    if (product.imageUrl.isNotEmpty) return [product.imageUrl];
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _product == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    if (_product == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_loadError ?? 'ບໍ່ພົບສິນຄ້າ'),
              const SizedBox(height: 16),
              FilledButton(onPressed: _load, child: const Text('ລອງໃໝ່')),
            ],
          ),
        ),
      );
    }

    final p = _product!;
    final gallery = _gallery;
    final safeIndex = gallery.isEmpty ? 0 : _selectedImageIndex.clamp(0, gallery.length - 1);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 320,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (gallery.isNotEmpty)
                    ProductImage(
                      imageUrl: gallery[safeIndex],
                      productName: p.name,
                      aspectRatio: 1,
                      borderRadius: 0,
                      fit: BoxFit.cover,
                    )
                  else
                    Container(color: AppColors.surface),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black.withValues(alpha: 0.15)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (gallery.length > 1)
            SliverToBoxAdapter(
              child: Container(
                color: AppColors.surface,
                padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.md),
                child: SizedBox(
                  height: 72,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: gallery.length,
                    separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final selected = index == safeIndex;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedImageIndex = index),
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selected ? AppColors.primary : AppColors.border,
                              width: selected ? 2 : 1,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: ProductImage(
                            imageUrl: gallery[index],
                            productName: p.name,
                            aspectRatio: 1,
                            borderRadius: 0,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
              ),
              transform: Matrix4.translationValues(0, gallery.length > 1 ? 0 : -20, 0),
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.xl, AppSpacing.xl, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (p.category.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        p.category,
                        style: GoogleFonts.notoSansLao(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    p.name,
                    style: GoogleFonts.notoSansLao(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PriceTag(amountLak: p.finalPriceLak, size: PriceTagSize.large),
                  const SizedBox(height: AppSpacing.xl),
                  Text(
                    'ລາຍລະອຽດ',
                    style: GoogleFonts.notoSansLao(fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    p.description.isNotEmpty ? p.description : 'ບໍ່ມີລາຍລະອຽດເພີ່ມເຕີມ',
                    style: GoogleFonts.notoSansLao(
                      fontSize: 14,
                      height: 1.6,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: AppColors.softShadow,
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('ລາຄາ', style: GoogleFonts.notoSansLao(fontSize: 12, color: AppColors.textMuted)),
                    PriceTag(amountLak: p.finalPriceLak, size: PriceTagSize.medium),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed: _addToCart,
                  icon: const Icon(Icons.shopping_bag_rounded),
                  label: const Text('ເພີ່ມໃສ່ກະຕ່າ'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
