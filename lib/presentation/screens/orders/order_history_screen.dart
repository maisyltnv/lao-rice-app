import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/product_image_url_resolver.dart';
import '../../../domain/entities/order_entity.dart';
import '../../providers/auth_provider.dart';
import '../../providers/catalog_provider.dart';
import '../../providers/orders_provider.dart';
import '../../widgets/customer_order_card.dart';
import '../../widgets/empty_state.dart';
import '../auth/phone_login_screen.dart';

/// Orders for the logged-in phone — auto-loaded; login required.
class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadIfSignedIn());
  }

  Future<void> _loadIfSignedIn() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isSignedIn) return;

    final phone = auth.phone?.trim() ?? '';
    if (phone.length < 8) return;

    final orders = context.read<OrdersProvider>();
    final catalog = context.read<CatalogProvider>();
    if (catalog.products.isEmpty) {
      await catalog.load();
    }
    await orders.searchByPhone(phone, refresh: true);
    if (!mounted) return;
    await _preloadOrderProductImages(orders.orders, catalog);
  }

  Future<void> _preloadOrderProductImages(
    List<OrderEntity> orderList,
    CatalogProvider catalog,
  ) async {
    final urls = <String>{};
    for (final order in orderList) {
      for (final item in order.items) {
        String? catalogUrl;
        for (final p in catalog.products) {
          if (p.id == item.productId) {
            catalogUrl = p.imageUrl;
            break;
          }
        }
        final url = item.effectiveImageUrl(
          productImageUrl: catalogUrl,
          orderPaymentReceiptUrl: order.paymentReceiptUrl,
        );
        if (url.isNotEmpty && !ProductImageUrlResolver.isDirectImageUrl(url)) {
          urls.add(url);
        }
      }
    }
    if (urls.isEmpty) return;
    await Future.wait(urls.map(ProductImageUrlResolver.shared.resolve));
  }

  Future<void> _refresh() async {
    await _loadIfSignedIn();
  }

  Future<void> _loadMore() async {
    final auth = context.read<AuthProvider>();
    if (!auth.isSignedIn) return;
    await context.read<OrdersProvider>().loadMore();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isReady) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    if (!auth.isSignedIn) {
      return PhoneLoginScreen(
        embedded: true,
        loginSubtitle: 'ຕ້ອງເຂົ້າລະບົບເພື່ອເບິ່ງຄຳສັ່ງຊື້',
        onSuccess: () {
          if (mounted) _loadIfSignedIn();
        },
      );
    }

    final orders = context.watch<OrdersProvider>();
    final accountPhone = auth.phone ?? '';

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: _refresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Text(
                'ຄຳສັ່ງຂອງເບີ $accountPhone',
                style: GoogleFonts.notoSansLao(
                  fontSize: 14,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
          if (orders.error != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Text(
                  orders.error!,
                  style: GoogleFonts.notoSansLao(
                    fontSize: 13,
                    color: AppColors.error,
                  ),
                ),
              ),
            ),
          if (orders.isLoading && orders.orders.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            )
          else if (orders.orders.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                icon: Icons.receipt_long_outlined,
                title: 'ຍັງບໍ່ມີຄຳສັ່ງ',
                subtitle: 'ສັ່ງຊື້ຈາກແທັບຮ້ານ ແລ້ວກັບມາເບິ່ງທີ່ນີ້',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.sm,
                AppSpacing.lg,
                AppSpacing.xl,
              ),
              sliver: SliverList.separated(
                itemCount: orders.orders.length + (orders.hasNext ? 1 : 0),
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, i) {
                  if (i == orders.orders.length) {
                    return Center(
                      child: TextButton(
                        onPressed: orders.isLoading ? null : _loadMore,
                        child: orders.isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                'ໂຫຼດເພີ່ມ',
                                style: GoogleFonts.notoSansLao(),
                              ),
                      ),
                    );
                  }
                  return CustomerOrderCard(order: orders.orders[i]);
                },
              ),
            ),
        ],
      ),
    );
  }
}
