import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../providers/orders_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/order_status_chip.dart';
import '../../widgets/price_tag.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final _phoneCtrl = TextEditingController();
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    final orders = context.read<OrdersProvider>();
    await orders.loadSavedPhone();
    if (orders.phone != null && orders.phone!.isNotEmpty) {
      _phoneCtrl.text = orders.phone!;
      await orders.searchByPhone(orders.phone!);
    }
    if (mounted) setState(() => _initialized = true);
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('ກະລຸນາໃສ່ເບີໂທທີ່ຖືກຕ້ອງ')),
      );
      return;
    }
    await context.read<OrdersProvider>().searchByPhone(phone);
  }

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrdersProvider>();

    if (!_initialized) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, AppSpacing.sm),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              boxShadow: AppColors.softShadow,
            ),
            padding: const EdgeInsets.all(AppSpacing.sm),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _phoneCtrl,
                    decoration: InputDecoration(
                      hintText: 'ເບີໂທທີ່ໃຊ້ສັ່ງຊື້',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.phone_rounded, color: AppColors.primary.withValues(alpha: 0.7)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    keyboardType: TextInputType.phone,
                    onSubmitted: (_) => _search(),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                FilledButton(
                  onPressed: orders.isLoading ? null : _search,
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  child: orders.isLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('ຄົ້ນຫາ'),
                ),
              ],
            ),
          ),
        ),
        Expanded(child: _buildBody(orders)),
      ],
    );
  }

  Widget _buildBody(OrdersProvider orders) {
    if (orders.error != null && orders.orders.isEmpty && !orders.isLoading) {
      return EmptyState(
        icon: Icons.error_outline_rounded,
        title: 'ຄົ້ນຫາບໍ່ສຳເລັດ',
        subtitle: orders.error,
        actionLabel: 'ລອງໃໝ່',
        onAction: _search,
      );
    }

    if (orders.orders.isEmpty && !orders.isLoading) {
      return const EmptyState(
        icon: Icons.receipt_long_outlined,
        title: 'ຄົ້ນຫາຄຳສັ່ງຊື້',
        subtitle: 'ໃສ່ເບີໂທທີ່ທ່ານໃຊ້ຕອນສັ່ງຊື້',
      );
    }

    if (orders.isLoading && orders.orders.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => orders.searchByPhone(_phoneCtrl.text.trim()),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 100),
        itemCount: orders.orders.length + (orders.hasNext ? 1 : 0),
        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
        itemBuilder: (context, i) {
          if (i >= orders.orders.length) {
            return Center(
              child: OutlinedButton(onPressed: orders.isLoading ? null : () => orders.loadMore(), child: const Text('ໂຫຼດເພີ່ມ')),
            );
          }
          final o = orders.orders[i];
          return Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              boxShadow: AppColors.softShadow,
            ),
            child: Theme(
              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 4),
                childrenPadding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, AppSpacing.lg),
                title: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            o.orderNumber.isNotEmpty ? o.orderNumber : '#${o.id}',
                            style: GoogleFonts.notoSansLao(fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            o.recipientName,
                            style: GoogleFonts.notoSansLao(fontSize: 13, color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    OrderStatusChip(status: o.status),
                  ],
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: PriceTag(amountLak: o.totalAmountLak, size: PriceTagSize.medium),
                ),
                children: [
                  if (o.items.isNotEmpty)
                    ...o.items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item.productName} ×${item.quantity}',
                                style: GoogleFonts.notoSansLao(fontSize: 13),
                              ),
                            ),
                            PriceTag(amountLak: item.lineTotalLak, size: PriceTagSize.small),
                          ],
                        ),
                      ),
                    ),
                  const Divider(),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${o.province} — ${o.addressDetail}',
                          style: GoogleFonts.notoSansLao(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
