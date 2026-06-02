import 'package:intl/intl.dart';

/// Formats amounts in Lao Kip (LAK): grouped digits, no fractional part by default.
class LakCurrencyFormatter {
  LakCurrencyFormatter._();

  // Match lao-rice-web formatting: `260.000 ₭`
  static final NumberFormat _grouped = NumberFormat('#,##0', 'lo_LA');

  /// [amount] is rounded to the nearest integer before display (typical for LAK).
  static String format(num amount, {bool showSymbol = true}) {
    final rounded = amount.round();
    final core = _grouped.format(rounded).replaceAll(',', '.');
    if (!showSymbol) return core;
    return '$core ₭';
  }

  static String formatWithSuffix(num amount) => '${format(amount, showSymbol: false)} LAK';
}
