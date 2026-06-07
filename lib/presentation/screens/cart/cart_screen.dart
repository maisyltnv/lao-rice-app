import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/price_tag.dart';
import '../../widgets/product_image.dart';
import '../../widgets/quantity_stepper.dart';
import '../auth/phone_login_screen.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    if (cart.isEmpty) {
      return const EmptyState(
        icon: Icons.shopping_bag_outlined,
        title: 'ກະຕ່າວ່າງ',
        subtitle: 'ເລືອກສິນຄ້າຈາກຫນ້າຮ້ານ ແລ້ວກົດ + ເພື່ອເພີ່ມ',
      );
    }

    return Column(
      children: [
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.md, AppSpacing.lg, 8),
            itemCount: cart.items.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
            itemBuilder: (context, i) {
              final item = cart.items[i];
              final p = item.product;
              return Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  boxShadow: AppColors.softShadow,
                ),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 80,
                      child: ProductImage(
                        imageUrl: p.imageUrl,
                        productName: p.name,
                        aspectRatio: 1,
                        borderRadius: AppSpacing.radiusSm,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.notoSansLao(fontWeight: FontWeight.w600, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          PriceTag(amountLak: p.finalPriceLak, size: PriceTagSize.small),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            children: [
                              QuantityStepper(
                                quantity: item.quantity,
                                onDecrement: item.quantity > 1
                                    ? () => cart.setQuantity(p.id, item.quantity - 1)
                                    : () => cart.remove(p.id),
                                onIncrement: () => cart.setQuantity(p.id, item.quantity + 1),
                              ),
                              const Spacer(),
                              PriceTag(amountLak: item.lineTotalLak, size: PriceTagSize.medium),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusXl)),
            boxShadow: AppColors.softShadow,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('ລວມຍ່ອຍ', style: GoogleFonts.notoSansLao(fontSize: 15, color: AppColors.textSecondary)),
                    PriceTag(amountLak: cart.subtotalLak, size: PriceTagSize.large),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  onPressed: () {
                    final auth = context.read<AuthProvider>();
                    if (!auth.isSignedIn) {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(builder: (_) => const PhoneLoginScreen()),
                      );
                      return;
                    }
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(builder: (_) => const CheckoutScreen()),
                    );
                  },
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: AppColors.primary,
                  ),
                  child: Text(
                    'ດຳເນີນການຊຳລະ (${cart.itemCount})',
                    style: GoogleFonts.notoSansLao(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
