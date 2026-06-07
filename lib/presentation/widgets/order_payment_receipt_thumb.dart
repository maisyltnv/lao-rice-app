import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/order_receipt_image.dart';
import 'image_preview_dialog.dart';

/// Payment receipt — small thumbnail, tap for full image (matches web).
class OrderPaymentReceiptThumb extends StatelessWidget {
  const OrderPaymentReceiptThumb({
    super.key,
    required this.paymentReceiptUrl,
    required this.paymentMethod,
  });

  final String paymentReceiptUrl;
  final String paymentMethod;

  @override
  Widget build(BuildContext context) {
    final resolved = orderReceiptImageUrl(paymentReceiptUrl);
    final isCod = paymentMethod == 'cod';
    final emptyMessage = isCod
        ? 'ຄຳສັ່ງ COD — ບໍ່ມີຮູບສະລິບການໂອນ'
        : 'ຍັງບໍ່ມີຮູບຫຼັກຖານການຊຳລະ';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.receipt_long_outlined, size: 16, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(
              'ຫຼັກຖານການຊຳລະເງິນ',
              style: GoogleFonts.notoSansLao(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (resolved.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border, style: BorderStyle.solid),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              color: AppColors.surfaceMuted.withValues(alpha: 0.5),
            ),
            child: Text(
              emptyMessage,
              style: GoogleFonts.notoSansLao(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          )
        else
          Row(
            children: [
              TappableImageThumbnail(
                imageUrl: resolved,
                previewTitle: 'ຫຼັກຖານການຊຳລະເງິນ',
                size: 64,
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'ແຕະຮູບເພື່ອເບິ່ງໃຫຍ່',
                  style: GoogleFonts.notoSansLao(
                    fontSize: 12,
                    color: AppColors.textMuted,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}
