import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

/// Rice shop brand mark (green/gold logo on white) — same asset as web `/logo.png`.
class BrandLogo extends StatelessWidget {
  const BrandLogo({
    super.key,
    this.size = 40,
    this.showShadow = false,
  });

  final double size;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: showShadow ? AppColors.softShadow : null,
      ),
      clipBehavior: Clip.antiAlias,
      child: Image.asset(
        'assets/brand/logo.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Icon(
          Icons.grain_rounded,
          color: AppColors.primary,
          size: size * 0.55,
        ),
      ),
    );
  }
}
