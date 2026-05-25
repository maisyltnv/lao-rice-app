import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/product_image_url_resolver.dart';
import '../../domain/entities/banner_entity.dart';

/// Full-width hero carousel fed by `GET /banners`.
class PromoBanner extends StatefulWidget {
  const PromoBanner({
    super.key,
    required this.banners,
    this.isLoading = false,
    this.onBannerTap,
  });

  final List<BannerEntity> banners;
  final bool isLoading;
  final void Function(BannerEntity banner)? onBannerTap;

  @override
  State<PromoBanner> createState() => _PromoBannerState();
}

class _PromoBannerState extends State<PromoBanner> {
  final _pageCtrl = PageController();
  Timer? _autoTimer;
  int _page = 0;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  @override
  void didUpdateWidget(PromoBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.banners.length != widget.banners.length) {
      _page = 0;
      _startAutoScroll();
    }
  }

  void _startAutoScroll() {
    _autoTimer?.cancel();
    if (widget.banners.length <= 1) return;
    _autoTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted || !_pageCtrl.hasClients || widget.banners.isEmpty) return;
      final next = (_page + 1) % widget.banners.length;
      _pageCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoTimer?.cancel();
    _pageCtrl.dispose();
    super.dispose();
  }

  double _heroHeight(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return (w * 0.44).clamp(168.0, 210.0);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return _BannerSkeleton(height: _heroHeight(context));
    }
    if (widget.banners.isEmpty) {
      return const SizedBox.shrink();
    }

    final height = _heroHeight(context);
    final count = widget.banners.length;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: double.infinity,
          height: height,
          child: PageView.builder(
            controller: _pageCtrl,
            itemCount: count,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, index) => _BannerSlideView(
              banner: widget.banners[index],
              onTap: widget.onBannerTap,
            ),
          ),
        ),
        if (count > 1) ...[
          const SizedBox(height: AppSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(count, (i) {
              final active = i == _page;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: active ? 18 : 6,
                height: 6,
                decoration: BoxDecoration(
                  color: active ? AppColors.primary : AppColors.border,
                  borderRadius: BorderRadius.circular(3),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _BannerSlideView extends StatefulWidget {
  const _BannerSlideView({required this.banner, this.onTap});

  final BannerEntity banner;
  final void Function(BannerEntity banner)? onTap;

  @override
  State<_BannerSlideView> createState() => _BannerSlideViewState();
}

class _BannerSlideViewState extends State<_BannerSlideView> {
  String? _resolvedImageUrl;

  @override
  void initState() {
    super.initState();
    _resolveImage();
  }

  @override
  void didUpdateWidget(_BannerSlideView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.banner.imageUrl != widget.banner.imageUrl) {
      _resolveImage();
    }
  }

  Future<void> _resolveImage() async {
    final raw = widget.banner.imageUrl.trim();
    if (raw.isEmpty) {
      if (mounted) setState(() => _resolvedImageUrl = null);
      return;
    }
    final resolved = await ProductImageUrlResolver.shared.resolve(raw);
    if (mounted) setState(() => _resolvedImageUrl = resolved);
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.banner;
    final imageUrl = _resolvedImageUrl;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: widget.onTap != null ? () => widget.onTap!(b) : null,
        child: Ink(
          decoration: const BoxDecoration(gradient: AppColors.heroGradient),
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.hardEdge,
            children: [
              if (imageUrl != null && imageUrl.isNotEmpty)
                Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withValues(alpha: 0.55),
                      Colors.black.withValues(alpha: 0.25),
                      Colors.black.withValues(alpha: 0.1),
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.22),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        b.displayBadge,
                        style: GoogleFonts.notoSansLao(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      b.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.notoSansLao(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                        letterSpacing: -0.5,
                      ),
                    ),
                    if (b.displaySubtitle.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        b.displaySubtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.notoSansLao(
                          color: Colors.white.withValues(alpha: 0.92),
                          fontSize: 13,
                          height: 1.25,
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    FilledButton(
                      onPressed: widget.onTap != null ? () => widget.onTap!(b) : null,
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: AppColors.onSecondary,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        minimumSize: const Size(0, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        b.displayCta,
                        style: GoogleFonts.notoSansLao(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                    ),
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

class _BannerSkeleton extends StatelessWidget {
  const _BannerSkeleton({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: ColoredBox(
        color: AppColors.surfaceMuted,
        child: const Center(
          child: SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
          ),
        ),
      ),
    );
  }
}
