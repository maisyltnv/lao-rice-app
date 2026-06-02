import 'package:flutter/material.dart';

import '../../core/constants/rice_images.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/product_image_url_resolver.dart';

class ProductImage extends StatefulWidget {
  const ProductImage({
    super.key,
    required this.imageUrl,
    this.productName,
    this.aspectRatio = 1,
    this.borderRadius = AppSpacing.radiusMd,
    this.fit = BoxFit.cover,
  });

  final String imageUrl;
  final String? productName;
  final double aspectRatio;
  final double borderRadius;
  final BoxFit fit;

  @override
  State<ProductImage> createState() => _ProductImageState();
}

class _ProductImageState extends State<ProductImage> {
  String? _networkUrl;
  bool _resolving = false;

  String get _assetPath => RiceImages.resolveAssetPath(
        widget.imageUrl,
        productName: widget.productName,
      );

  bool get _useBundledAsset {
    final raw = widget.imageUrl.trim();
    return RiceImages.isBundledAssetPath(raw);
  }

  @override
  void initState() {
    super.initState();
    _resolveUrl();
  }

  @override
  void didUpdateWidget(ProductImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl ||
        oldWidget.productName != widget.productName) {
      _resolveUrl();
    }
  }

  Future<void> _resolveUrl() async {
    if (_useBundledAsset) {
      if (mounted) {
        setState(() {
          _networkUrl = null;
          _resolving = false;
        });
      }
      return;
    }

    final raw = widget.imageUrl.trim();
    if (ProductImageUrlResolver.isDirectImageUrl(raw)) {
      if (mounted) {
        setState(() {
          _networkUrl = raw;
          _resolving = false;
        });
      }
      return;
    }

    if (mounted) setState(() => _resolving = true);
    final resolved = await ProductImageUrlResolver.shared.resolve(raw);
    if (!mounted) return;
    setState(() {
      _networkUrl = resolved;
      _resolving = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.borderRadius),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildAssetImage() {
    return Image.asset(
      _assetPath,
      fit: widget.fit,
      width: double.infinity,
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => _iconPlaceholder(),
    );
  }

  Widget _buildContent() {
    if (_resolving) {
      return _loadingBox();
    }

    if (_useBundledAsset) {
      return _buildAssetImage();
    }

    final url = _networkUrl ?? '';
    if (url.isEmpty || !ProductImageUrlResolver.isDirectImageUrl(url)) {
      return _buildAssetImage();
    }

    return Image.network(
      url,
      fit: widget.fit,
      width: double.infinity,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _loadingBox();
      },
      errorBuilder: (_, _, _) => _buildAssetImage(),
    );
  }

  Widget _loadingBox() {
    return Container(
      color: AppColors.surfaceMuted,
      alignment: Alignment.center,
      child: const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _iconPlaceholder() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.accent,
            AppColors.primary.withValues(alpha: 0.12),
          ],
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        Icons.rice_bowl_rounded,
        size: 36,
        color: AppColors.primary.withValues(alpha: 0.55),
      ),
    );
  }
}
