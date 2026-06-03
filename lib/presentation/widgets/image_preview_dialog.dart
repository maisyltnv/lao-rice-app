import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import 'product_image.dart';

/// Opens a dialog with a large zoomable image (product or payment receipt).
void showImagePreviewDialog(
  BuildContext context, {
  required String imageUrl,
  String? productName,
  String title = 'ເບິ່ງຮູບ',
}) {
  showDialog<void>(
    context: context,
    barrierColor: Colors.black54,
    builder: (ctx) => Dialog(
      insetPadding: const EdgeInsets.all(AppSpacing.lg),
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(ctx).height * 0.85,
          maxWidth: MediaQuery.sizeOf(ctx).width - AppSpacing.lg * 2,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.sm, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: GoogleFonts.notoSansLao(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(ctx).pop(),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  child: InteractiveViewer(
                    minScale: 0.5,
                    maxScale: 4,
                    child: ProductImage(
                      imageUrl: imageUrl,
                      productName: productName,
                      aspectRatio: 1,
                      fit: BoxFit.contain,
                      borderRadius: 0,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Small thumbnail; tap to open [showImagePreviewDialog].
class TappableImageThumbnail extends StatelessWidget {
  const TappableImageThumbnail({
    super.key,
    required this.imageUrl,
    this.productName,
    this.previewTitle = 'ເບິ່ງຮູບ',
    this.size = 56,
  });

  final String imageUrl;
  final String? productName;
  final String previewTitle;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => showImagePreviewDialog(
          context,
          imageUrl: imageUrl,
          productName: productName,
          title: previewTitle,
        ),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: SizedBox(
          width: size,
          height: size,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: ProductImage(
                  imageUrl: imageUrl,
                  productName: productName,
                  aspectRatio: 1,
                  fit: BoxFit.cover,
                  borderRadius: AppSpacing.radiusMd,
                ),
              ),
              Positioned(
                right: 2,
                bottom: 2,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.45),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(Icons.zoom_in, size: 14, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
