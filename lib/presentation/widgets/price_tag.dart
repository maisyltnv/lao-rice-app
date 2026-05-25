import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/lak_currency_formatter.dart';

class PriceTag extends StatelessWidget {
  const PriceTag({
    super.key,
    required this.amountLak,
    this.size = PriceTagSize.medium,
    this.light = false,
  });

  final double amountLak;
  final PriceTagSize size;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final fontSize = switch (size) {
      PriceTagSize.small => 13.0,
      PriceTagSize.medium => 15.0,
      PriceTagSize.large => 22.0,
    };

    return Text(
      LakCurrencyFormatter.format(amountLak),
      style: GoogleFonts.notoSansLao(
        fontSize: fontSize,
        fontWeight: FontWeight.w800,
        color: light ? Colors.white : AppColors.primary,
        letterSpacing: -0.5,
      ),
    );
  }
}

enum PriceTagSize { small, medium, large }
