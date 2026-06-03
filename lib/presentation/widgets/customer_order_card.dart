import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/lak_currency_formatter.dart';
import '../../core/utils/order_labels.dart';
import '../../domain/entities/order_entity.dart';
import 'image_preview_dialog.dart';
import 'order_payment_receipt_thumb.dart';
import 'order_status_chip.dart';

/// Collapsible order card — summary first, tap chevron for full details (web parity).
class CustomerOrderCard extends StatefulWidget {
  const CustomerOrderCard({super.key, required this.order});

  final OrderEntity order;

  @override
  State<CustomerOrderCard> createState() => _CustomerOrderCardState();
}

class _CustomerOrderCardState extends State<CustomerOrderCard> {
  bool _expanded = false;

  OrderEntity get order => widget.order;

  @override
  Widget build(BuildContext context) {
    final itemCount = order.items.fold<int>(0, (s, i) => s + i.quantity);
    final itemsSubtotal = order.items.fold<double>(
      0,
      (s, i) => s + i.lineTotalLak,
    );
    final subtotal = order.subtotalLak > 0 ? order.subtotalLak : itemsSubtotal;
    final shipping = order.shippingFeeLak;
    final addressParts = <String>[
      if (order.province.trim().isNotEmpty) order.province.trim(),
      if (order.addressDetail.trim().isNotEmpty) order.addressDetail.trim(),
    ];
    final addressLine = addressParts.join(' · ');
    final firstItemName =
        order.items.isNotEmpty ? order.items.first.productName : null;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppColors.softShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Wrap(
                                crossAxisAlignment: WrapCrossAlignment.center,
                                spacing: 8,
                                runSpacing: 4,
                                children: [
                                  Text(
                                    order.orderNumber,
                                    style: GoogleFonts.notoSansLao(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  OrderStatusChip(
                                    status: order.status,
                                    label: orderStatusLabelLao(order.status),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                formatOrderDateLao(order.createdAt),
                                style: GoogleFonts.notoSansLao(
                                  fontSize: 12,
                                  color: AppColors.textMuted,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                _collapsedSummary(
                                  itemCount: itemCount,
                                  firstItemName: firstItemName,
                                ),
                                style: GoogleFonts.notoSansLao(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              formatLakWeb(order.totalAmountLak),
                              style: GoogleFonts.notoSansLao(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: AppColors.primary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            AnimatedRotation(
                              turns: _expanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: const Icon(
                                Icons.keyboard_arrow_down,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      _expanded
                          ? 'ແຕະເພື່ອຫຍໍ້ລາຍລະອຽດ'
                          : 'ແຕະເພື່ອເບິ່ງລາຍລະອຽດຄຳສັ່ງ',
                      style: GoogleFonts.notoSansLao(
                        fontSize: 11,
                        color: AppColors.primary.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _expanded
                ? _expandedDetails(
                    itemCount: itemCount,
                    subtotal: subtotal,
                    shipping: shipping,
                    addressLine: addressLine,
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  String _collapsedSummary({
    required int itemCount,
    required String? firstItemName,
  }) {
    final parts = <String>[order.recipientName];
    if (itemCount > 0) parts.add('$itemCount ຊິ້ນ');
    if (!_expanded && firstItemName != null && firstItemName.isNotEmpty) {
      parts.add(firstItemName);
    }
    return parts.join(' · ');
  }

  Widget _expandedDetails({
    required int itemCount,
    required double subtotal,
    required double shipping,
    required String addressLine,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: AppSpacing.md),
          _infoRow(Icons.person_outline, order.recipientName),
          _infoRow(Icons.phone_outlined, order.phone),
          if (addressLine.isNotEmpty)
            _infoRow(Icons.location_on_outlined, addressLine),
          _infoRow(
            Icons.payments_outlined,
            orderPaymentLabelLao(order.paymentMethod),
          ),
          if (order.items.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
              child: Divider(height: 1),
            ),
            Row(
              children: [
                Icon(Icons.inventory_2_outlined,
                    size: 16, color: AppColors.textMuted),
                const SizedBox(width: 6),
                Text(
                  'ລາຍການສິນຄ້າ ($itemCount ຊິ້ນ)',
                  style: GoogleFonts.notoSansLao(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TappableImageThumbnail(
                      imageUrl: item.imageUrl,
                      productName: item.productName,
                      previewTitle: item.productName,
                      size: 56,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: GoogleFonts.notoSansLao(fontSize: 13),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            '×${item.quantity}',
                            style: GoogleFonts.notoSansLao(
                              fontSize: 12,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      formatLakWeb(item.lineTotalLak),
                      style: GoogleFonts.notoSansLao(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: Text(
                'ບໍ່ມີລາຍລະອຽດສິນຄ້າໃນຄຳສັ່ງນີ້',
                style: GoogleFonts.notoSansLao(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: Divider(height: 1),
          ),
          _priceRow('ລວມສິນຄ້າ', formatLakWeb(subtotal)),
          _priceRow(
            'ຄ່າຈັດສົ່ງ',
            shipping <= 0 ? 'ຟຣີ' : formatLakWeb(shipping),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ລວມທັງໝົດ',
                style: GoogleFonts.notoSansLao(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              Text(
                formatLakWeb(order.totalAmountLak),
                style: GoogleFonts.notoSansLao(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(top: AppSpacing.md),
            child: Divider(height: 1),
          ),
          OrderPaymentReceiptThumb(
            paymentReceiptUrl: order.paymentReceiptUrl,
            paymentMethod: order.paymentMethod,
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppColors.textMuted),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.notoSansLao(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.notoSansLao(
              fontSize: 13,
              color: AppColors.textMuted,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.notoSansLao(fontSize: 13),
          ),
        ],
      ),
    );
  }
}
