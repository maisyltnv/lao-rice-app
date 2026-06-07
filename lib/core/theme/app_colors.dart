import 'package:flutter/material.dart';

/// Lao Rice Shop — warm golden brown & harvest gold palette.
abstract final class AppColors {
  static const Color primary = Color(0xFF7C5C1E);
  static const Color primaryDark = Color(0xFF5C4315);
  static const Color primaryLight = Color(0xFFB8860B);
  static const Color primaryDeep = Color(0xFF3D2E14);

  static const Color secondary = Color(0xFFD4A017);
  static const Color onSecondary = Color(0xFF2A1F0A);

  static const Color accent = Color(0xFFFFF4E0);
  static const Color accentForeground = Color(0xFF5C4315);

  static const Color background = Color(0xFFFFFAF5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF5E8D0);

  static const Color textPrimary = Color(0xFF3D2E1A);
  static const Color textSecondary = Color(0xFF6B5A45);
  static const Color textMuted = Color(0xFF9A8B78);

  static const Color border = Color(0xFFE8DCC8);

  static const Color success = Color(0xFF4A7C59);
  static const Color warning = Color(0xFFD4A017);
  static const Color error = Color(0xFFC0392B);

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, primaryLight],
  );

  /// Soft warm card for the customer profile header.
  static const LinearGradient profileHeaderGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFCF7), Color(0xFFF3E8D4)],
  );

  static const LinearGradient promoGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primary, Color(0xFF9A7224)],
  );

  static const LinearGradient cardShine = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x00FFFFFF), Color(0x0D000000)],
  );

  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: primary.withValues(alpha: 0.12),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 6,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get softShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];
}
