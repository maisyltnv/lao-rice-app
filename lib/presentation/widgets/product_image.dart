import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/api_media_url.dart';
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

  @override
  void initState() {
    super.initState();
    _resolveUrl();
  }

  @override
  void didUpdateWidget(ProductImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.imageUrl != widget.imageUrl) {
      _resolveUrl();
    }
  }

  Future<void> _resolveUrl() async {
    final raw = widget.imageUrl.trim();
    if (raw.isEmpty) {
      if (mounted) {
        setState(() {
          _networkUrl = null;
          _resolving = false;
        });
      }
      return;
    }

    final absolute = ApiMediaUrl.resolve(raw);
    if (absolute.isEmpty) {
      if (mounted) {
        setState(() {
          _networkUrl = null;
          _resolving = false;
        });
      }
      return;
    }

    if (ProductImageUrlResolver.isDirectImageUrl(absolute)) {
      if (mounted) {
        setState(() {
          _networkUrl = absolute;
          _resolving = false;
        });
      }
      return;
    }

    if (mounted) setState(() => _resolving = true);
    final resolved = await ProductImageUrlResolver.shared.resolve(absolute);
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

  Widget _buildContent() {
    if (_resolving) {
      return _loadingBox();
    }

    final url = _networkUrl ?? '';
    if (url.isEmpty || !ProductImageUrlResolver.isDirectImageUrl(url)) {
      return _noImagePlaceholder();
    }

    return Image.network(
      url,
      fit: widget.fit,
      width: double.infinity,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return _loadingBox();
      },
      errorBuilder: (_, _, _) => _noImagePlaceholder(),
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

  Widget _noImagePlaceholder() {
    return Container(
      width: double.infinity,
      color: AppColors.surfaceMuted,
      alignment: Alignment.center,
      child: Text(
        'no image',
        style: TextStyle(
          fontSize: 12,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}
