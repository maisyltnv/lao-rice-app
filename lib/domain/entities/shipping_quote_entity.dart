import '../../core/utils/lak_amount.dart';

class ShippingQuoteEntity {
  const ShippingQuoteEntity({
    required this.subtotalLak,
    required this.shippingFeeLak,
    required this.totalAmountLak,
    required this.freeShippingApplied,
    this.amountUntilFreeShippingLak,
  });

  final double subtotalLak;
  final double shippingFeeLak;
  final double totalAmountLak;
  final bool freeShippingApplied;
  final double? amountUntilFreeShippingLak;

  factory ShippingQuoteEntity.fromJson(Map<String, dynamic> j) {
    return ShippingQuoteEntity(
      subtotalLak: LakAmount.normalize(j['subtotal_lak'] as num?),
      shippingFeeLak: LakAmount.normalize(j['shipping_fee_lak'] as num?),
      totalAmountLak: LakAmount.normalize(j['total_amount_lak'] as num?),
      freeShippingApplied: j['free_shipping_applied'] as bool? ?? false,
      amountUntilFreeShippingLak: LakAmount.normalizeNullable(j['amount_until_free_shipping_lak'] as num?),
    );
  }
}
