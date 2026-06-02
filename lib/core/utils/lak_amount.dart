/// Normalizes LAK amounts coming from APIs.
///
/// Some deployments store prices in "thousand kip" (e.g. `260` means `260000` LAK).
/// We treat values in (0, 1000) as thousand-kip and scale by 1000.
abstract final class LakAmount {
  LakAmount._();

  static double normalize(num? raw) {
    final v = raw?.toDouble() ?? 0;
    if (v > 0 && v < 1000) return v * 1000;
    return v;
  }

  static double? normalizeNullable(num? raw) {
    if (raw == null) return null;
    return normalize(raw);
  }
}

