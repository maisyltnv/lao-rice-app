import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/banner_link_handler.dart';
import '../../../domain/entities/banner_entity.dart';
import '../../providers/banners_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/product_card.dart';
import '../../widgets/promo_banner.dart';
import '../scan/qr_scan_screen.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogProvider>();
    final banners = context.watch<BannersProvider>();
    final isSearching = catalog.isSearching;
    final products = catalog.products;

    if (catalog.isLoading && products.isEmpty && !isSearching) {
      return const _HomeLoading();
    }

    if (catalog.error != null && products.isEmpty && !isSearching) {
      return EmptyState(
        icon: Icons.cloud_off_rounded,
        title: 'ບໍ່ສາມາດເຊື່ອມ API',
        subtitle: catalog.error,
        actionLabel: 'ລອງໃໝ່',
        onAction: catalog.load,
      );
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        await Future.wait([catalog.load(), banners.load()]);
      },
      child: CustomScrollView(
        key: const PageStorageKey<String>('home_scroll'),
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _HomeHeader(
              searchCtrl: _searchCtrl,
              hasQuery: isSearching,
              isLoading: catalog.isLoading && isSearching,
              onSearchChanged: catalog.setSearchQuery,
              onSearchClear: () {
                _searchCtrl.clear();
                catalog.clearSearch();
              },
            ),
          ),
          SliverToBoxAdapter(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isSearching
                  ? const SizedBox(height: AppSpacing.lg, key: ValueKey('search_gap'))
                  : Column(
                      key: const ValueKey('home_extras'),
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: AppSpacing.md),
                        PromoBanner(
                          banners: banners.banners,
                          isLoading: banners.isLoading,
                          onBannerTap: (b) => _onBannerTap(context, catalog, b),
                        ),
                        if (banners.hasBanners || banners.isLoading)
                          const SizedBox(height: AppSpacing.lg),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                          child: Row(
                            children: [
                              Text(
                                'ຫມວດສິນຄ້າ',
                                style: GoogleFonts.notoSansLao(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              const Spacer(),
                              TextButton.icon(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(builder: (_) => const QrScanScreen()),
                                ),
                                icon: const Icon(Icons.qr_code_scanner_rounded, size: 18),
                                label: const Text('ສະແກນ'),
                                style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        SizedBox(
                          height: 44,
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                            scrollDirection: Axis.horizontal,
                            itemCount: catalog.categoryChips.length,
                            separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
                            itemBuilder: (context, i) {
                              final chip = catalog.categoryChips[i];
                              final selected = catalog.selectedCategoryId == chip.id;
                              return FilterChip(
                                key: ValueKey('cat_${chip.id}'),
                                label: Text(chip.label),
                                selected: selected,
                                showCheckmark: true,
                                onSelected: (_) => catalog.selectCategory(chip.id),
                                selectedColor: AppColors.primary,
                                labelStyle: GoogleFonts.notoSansLao(
                                  fontWeight: FontWeight.w600,
                                  color: selected ? Colors.white : AppColors.textSecondary,
                                ),
                                backgroundColor: AppColors.surface,
                                side: BorderSide(color: selected ? AppColors.primary : AppColors.border),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.xl, AppSpacing.lg, AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      isSearching ? 'ຜົນການຄົ້ນຫາ (${catalog.total})' : 'ສິນຄ້າແນະນຳ',
                      style: GoogleFonts.notoSansLao(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  if (isSearching)
                    TextButton(
                      onPressed: () {
                        _searchCtrl.clear();
                        catalog.clearSearch();
                      },
                      child: const Text('ລ້າງ'),
                    ),
                ],
              ),
            ),
          ),
          if (catalog.isLoading && products.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
              ),
            )
          else if (products.isEmpty)
            SliverToBoxAdapter(
              child: SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.35,
                child: EmptyState(
                  icon: isSearching ? Icons.search_off_rounded : Icons.inventory_2_outlined,
                  title: isSearching ? 'ບໍ່ພົບສິນຄ້າ' : 'ບໍ່ມີສິນຄ້າໃນຫມວດນີ້',
                  subtitle: isSearching ? 'ລອງຄຳອື່ນ ຫຼື ກວດສອບການສະກົດ' : 'ລອງເລືອກຫມວດອື່ນ',
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 100),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 0.62,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final p = products[index];
                    return ProductCard(
                      key: ValueKey('product_${p.id}'),
                      product: p,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ProductDetailScreen(productId: p.id, initial: p),
                        ),
                      ),
                      onAddToCart: () {
                        context.read<CartProvider>().add(p);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('ເພີ່ມ "${p.name}" ໃສ່ກະຕ່າແລ້ວ'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    );
                  },
                  childCount: products.length,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _onBannerTap(BuildContext context, CatalogProvider catalog, BannerEntity banner) {
    switch (parseBannerLink(banner.linkUrl)) {
      case BannerLinkProduct(:final productId):
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => ProductDetailScreen(productId: productId),
          ),
        );
      case BannerLinkCategory(:final categoryId):
        catalog.selectCategory(categoryId);
      case BannerLinkShowAll():
        catalog.selectCategory(null);
    }
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.searchCtrl,
    required this.hasQuery,
    required this.isLoading,
    required this.onSearchChanged,
    required this.onSearchClear,
  });

  final TextEditingController searchCtrl;
  final bool hasQuery;
  final bool isLoading;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchClear;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppColors.heroGradient,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: const Icon(Icons.rice_bowl_rounded, color: Colors.white, size: 24),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ສະບາຍດີ 👋',
                        style: GoogleFonts.notoSansLao(fontSize: 13, color: AppColors.textSecondary),
                      ),
                      Text(
                        'ຮ້ານເຂົ້າສານ',
                        style: GoogleFonts.notoSansLao(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: searchCtrl,
              onChanged: onSearchChanged,
              onSubmitted: (v) {
                onSearchChanged(v);
                FocusScope.of(context).unfocus();
              },
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'ຄົ້ນຫາສິນຄ້າ, ລາຍລະອຽດ...',
                prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted),
                suffixIcon: isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                        ),
                      )
                    : hasQuery
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded, size: 20),
                            onPressed: onSearchClear,
                          )
                        : null,
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: const BorderSide(color: AppColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeLoading extends StatelessWidget {
  const _HomeLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        const SizedBox(height: 60),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Container(
          height: 180,
          width: double.infinity,
          color: AppColors.surfaceMuted,
        ),
        const SizedBox(height: AppSpacing.xl),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.62,
          ),
          itemCount: 4,
          itemBuilder: (context, i) => Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
          ),
        ),
      ],
    );
  }
}
