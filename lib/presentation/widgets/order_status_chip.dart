import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';

class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({
    super.key,
    required this.status,
    this.label,
  });

  final String status;
  /// Display text (e.g. Lao); colors still derive from [status].
  final String? label;

  @override
  Widget build(BuildContext context) {
    final (color, bg) = _colors(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        label ?? status,
        style: GoogleFonts.notoSansLao(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  (Color, Color) _colors(String s) {
    final lower = s.toLowerCase();
    if (lower.contains('pending')) return (AppColors.warning, AppColors.warning.withValues(alpha: 0.12));
    if (lower.contains('paid') || lower.contains('confirm')) {
      return (AppColors.success, AppColors.success.withValues(alpha: 0.12));
    }
    if (lower.contains('cancel')) return (AppColors.error, AppColors.error.withValues(alpha: 0.12));
    return (AppColors.primary, AppColors.primary.withValues(alpha: 0.12));
  }
}
