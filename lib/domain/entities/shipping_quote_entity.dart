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
      subtotalLak: (j['subtotal_lak'] as num?)?.toDouble() ?? 0,
      shippingFeeLak: (j['shipping_fee_lak'] as num?)?.toDouble() ?? 0,
      totalAmountLak: (j['total_amount_lak'] as num?)?.toDouble() ?? 0,
      freeShippingApplied: j['free_shipping_applied'] as bool? ?? false,
      amountUntilFreeShippingLak: (j['amount_until_free_shipping_lak'] as num?)?.toDouble(),
    );
  }
}
