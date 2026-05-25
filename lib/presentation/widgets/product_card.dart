import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../domain/entities/product_entity.dart';
import 'price_tag.dart';
import 'product_image.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
    this.onAddToCart,
  });

  final ProductEntity product;
  final VoidCallback onTap;
  final VoidCallback? onAddToCart;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            boxShadow: AppColors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: ProductImage(
                        imageUrl: product.imageUrl,
                        productName: product.name,
                        aspectRatio: 0.92,
                        borderRadius: AppSpacing.radiusMd,
                      ),
                    ),
                    if (product.category.isNotEmpty)
                      Positioned(
                        top: AppSpacing.md,
                        left: AppSpacing.md,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            product.category,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.notoSansLao(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    if (onAddToCart != null)
                      Positioned(
                        right: AppSpacing.md,
                        bottom: AppSpacing.md,
                        child: Material(
                          color: AppColors.primary,
                          elevation: 4,
                          shadowColor: AppColors.primary.withValues(alpha: 0.4),
                          shape: const CircleBorder(),
                          child: InkWell(
                            onTap: onAddToCart,
                            customBorder: const CircleBorder(),
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(Icons.add, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.notoSansLao(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    PriceTag(amountLak: product.finalPriceLak, size: PriceTagSize.medium),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
