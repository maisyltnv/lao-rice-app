import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/checkout_layout.dart';
import '../../../core/utils/lak_currency_formatter.dart' show formatLakWeb;
import '../../../domain/entities/cart_item_entity.dart';
import '../../../domain/entities/shipping_quote_entity.dart';
import '../../widgets/product_image.dart';

class CheckoutStepIndicator extends StatelessWidget {
  const CheckoutStepIndicator({super.key, required this.currentStep});

  final int currentStep;

  static const _steps = [
    (id: 1, label: 'ທີ່ຢູ່ຈັດສົ່ງ', icon: Icons.local_shipping_outlined),
    (id: 2, label: 'ການຊຳລະເງິນ', icon: Icons.credit_card_outlined),
    (id: 3, label: 'ຢືນຢັນຄຳສັ່ງ', icon: Icons.check_circle_outline),
  ];

  @override
  Widget build(BuildContext context) {
    final compact = MediaQuery.sizeOf(context).height < 700;
    final dotSize = compact ? 34.0 : 40.0;
    final labelWidth = compact ? 64.0 : 72.0;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: compact ? AppSpacing.md : AppSpacing.lg,
        horizontal: AppSpacing.md,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceMuted,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: constraints.maxWidth),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < _steps.length; i++) ...[
                    if (i > 0)
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: compact ? 4 : 6),
                        child: Icon(
                          Icons.chevron_right_rounded,
                          size: compact ? 18 : 20,
                          color: currentStep > i ? AppColors.primary : AppColors.textMuted,
                        ),
                      ),
                    _StepDot(
                      step: _steps[i],
                      active: currentStep >= _steps[i].id,
                      completed: currentStep > _steps[i].id,
                      dotSize: dotSize,
                      labelWidth: labelWidth,
                      compact: compact,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  const _StepDot({
    required this.step,
    required this.active,
    required this.completed,
    required this.dotSize,
    required this.labelWidth,
    required this.compact,
  });

  final ({int id, String label, IconData icon}) step;
  final bool active;
  final bool completed;
  final double dotSize;
  final double labelWidth;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final color = active ? AppColors.primary : AppColors.textMuted;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: active ? AppColors.primary : AppColors.border,
            shape: BoxShape.circle,
          ),
          child: Icon(
            completed ? Icons.check_rounded : step.icon,
            size: compact ? 18 : 20,
            color: active ? Colors.white : AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: labelWidth,
          child: Text(
            step.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.notoSansLao(
              fontSize: compact ? 9 : 10,
              fontWeight: FontWeight.w600,
              color: color,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

class OrderSummaryCard extends StatelessWidget {
  const OrderSummaryCard({
    super.key,
    required this.items,
    required this.subtotalLak,
    required this.shippingFeeLak,
    required this.totalLak,
    this.quote,
    this.quoteLoading = false,
    this.showLineItems = true,
    this.compact = false,
  });

  final List<CartItemEntity> items;
  final double subtotalLak;
  final double shippingFeeLak;
  final double totalLak;
  final ShippingQuoteEntity? quote;
  final bool quoteLoading;
  final bool showLineItems;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final freeShipping = quote?.freeShippingApplied ?? shippingFeeLak == 0;
    final cardPadding = compact ? AppSpacing.md : AppSpacing.lg;

    return Container(
      margin: EdgeInsets.only(bottom: compact ? AppSpacing.md : AppSpacing.lg),
      padding: EdgeInsets.all(cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ສະຫຼຸບຄຳສັ່ງຊື້',
            style: GoogleFonts.notoSansLao(
              fontSize: compact ? 14 : 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (showLineItems && items.isNotEmpty) ...[
            SizedBox(height: compact ? AppSpacing.md : AppSpacing.lg),
            ...items.map(_SummaryLineItem.new),
            Divider(height: compact ? AppSpacing.lg : AppSpacing.xl),
          ] else
            SizedBox(height: compact ? AppSpacing.sm : AppSpacing.md),
          _priceRow('ລວມສິນຄ້າ', formatLakWeb(subtotalLak), compact: compact),
          const SizedBox(height: AppSpacing.sm),
          _priceRow(
            'ຄ່າຈັດສົ່ງ',
            quoteLoading
                ? '...'
                : freeShipping
                    ? 'ຟຣີ'
                    : formatLakWeb(shippingFeeLak),
            valueColor: freeShipping ? AppColors.primary : null,
            compact: compact,
          ),
          Divider(height: compact ? AppSpacing.md : AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ລວມທັງໝົດ',
                style: GoogleFonts.notoSansLao(
                  fontSize: compact ? 14 : 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Flexible(
                child: Text(
                  formatLakWeb(totalLak),
                  textAlign: TextAlign.end,
                  style: GoogleFonts.notoSansLao(
                    fontSize: compact ? 16 : 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          if (freeShipping) ...[
            const SizedBox(height: AppSpacing.md),
            Center(
              child: Text(
                'ຮັບການຈັດສົ່ງຟຣີແລ້ວ',
                style: GoogleFonts.notoSansLao(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
              ),
            ),
          ] else if (quote?.amountUntilFreeShippingLak != null && quote!.amountUntilFreeShippingLak! > 0) ...[
            const SizedBox(height: AppSpacing.md),
            Center(
              child: Text(
                quoteLoading
                    ? 'ກຳລັງຄິດຄ່າສົ່ງ...'
                    : 'ຊື້ເພີ່ມອີກ ${formatLakWeb(quote!.amountUntilFreeShippingLak!)} ເພື່ອຮັບການຈັດສົ່ງຟຣີ',
                textAlign: TextAlign.center,
                style: GoogleFonts.notoSansLao(fontSize: 11, color: AppColors.textMuted),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, {Color? valueColor, bool compact = false}) {
    final fontSize = compact ? 13.0 : 14.0;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            label,
            style: GoogleFonts.notoSansLao(fontSize: fontSize, color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          value,
          style: GoogleFonts.notoSansLao(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

class _SummaryLineItem extends StatelessWidget {
  const _SummaryLineItem(this.item);

  final CartItemEntity item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: ProductImage(
                  imageUrl: item.product.imageUrl,
                  productName: item.product.name,
                  aspectRatio: 1,
                  borderRadius: AppSpacing.radiusSm,
                ),
              ),
              Positioned(
                top: -6,
                right: -6,
                child: Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: Text(
                    '${item.quantity}',
                    style: GoogleFonts.notoSansLao(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              item.product.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.notoSansLao(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            formatLakWeb(item.lineTotalLak),
            style: GoogleFonts.notoSansLao(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class CheckoutLabeledField extends StatelessWidget {
  const CheckoutLabeledField({
    super.key,
    required this.icon,
    required this.label,
    required this.child,
  });

  final IconData icon;
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 6),
            Text(label, style: GoogleFonts.notoSansLao(fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        child,
      ],
    );
  }
}

class CheckoutReviewCard extends StatelessWidget {
  const CheckoutReviewCard({
    super.key,
    required this.title,
    required this.onEdit,
    required this.child,
  });

  final String title;
  final VoidCallback onEdit;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(title, style: GoogleFonts.notoSansLao(fontSize: 15, fontWeight: FontWeight.w700)),
              ),
              TextButton(
                onPressed: onEdit,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text('ແກ້ໄຂ', style: GoogleFonts.notoSansLao(fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          child,
        ],
      ),
    );
  }
}

class PaymentMethodTile extends StatelessWidget {
  const PaymentMethodTile({
    super.key,
    required this.selected,
    required this.icon,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final Color iconBg;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Ink(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary.withValues(alpha: 0.06) : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 2 : 1),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: Colors.white, size: 26),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: GoogleFonts.notoSansLao(fontSize: 15, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.notoSansLao(fontSize: 12, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              if (selected) const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class CheckoutNavButtons extends StatelessWidget {
  const CheckoutNavButtons({
    super.key,
    this.showBack = true,
    required this.onBack,
    required this.onContinue,
    this.continueLabel = 'ດຳເນີນການຕໍ່',
    this.continueLoading = false,
    this.continueEnabled = true,
    this.compact = false,
  });

  final bool showBack;
  final VoidCallback onBack;
  final VoidCallback onContinue;
  final String continueLabel;
  final bool continueLoading;
  final bool continueEnabled;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final vPadding = compact ? 12.0 : 14.0;
    return Row(
      children: [
        if (showBack) ...[
          Expanded(
            child: OutlinedButton(
              onPressed: continueLoading ? null : onBack,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: vPadding),
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
              ),
              child: Text('ກັບຄືນ', style: GoogleFonts.notoSansLao(fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
        ],
        Expanded(
          child: FilledButton(
            onPressed: continueLoading || !continueEnabled ? null : onContinue,
            style: FilledButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: vPadding),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
            ),
            child: continueLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          continueLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.notoSansLao(fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right_rounded, size: 20),
                    ],
                  ),
          ),
        ),
      ],
    );
  }
}

/// Sticky footer wrapper for checkout primary actions (place inside [Column] body).
class CheckoutBottomBar extends StatelessWidget {
  const CheckoutBottomBar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final padding = CheckoutLayout.pagePadding(context);
    return Material(
      color: AppColors.surface,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          padding.left,
          AppSpacing.md,
          padding.right,
          AppSpacing.md,
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: CheckoutLayout.maxContentWidth),
            child: SizedBox(width: double.infinity, child: child),
          ),
        ),
      ),
    );
  }
}
