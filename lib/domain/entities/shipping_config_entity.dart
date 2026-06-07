/// Public shop settings from `GET /orders/shipping-config`.
class ShippingConfigEntity {
  const ShippingConfigEntity({
    required this.shippingFeeLak,
    required this.freeShippingMinSubtotalLak,
    required this.bcelQrEnabled,
    required this.codEnabled,
  });

  final double shippingFeeLak;
  final double freeShippingMinSubtotalLak;
  final bool bcelQrEnabled;
  final bool codEnabled;

  factory ShippingConfigEntity.fromJson(Map<String, dynamic> json) {
    return ShippingConfigEntity(
      shippingFeeLak: (json['shipping_fee_lak'] as num?)?.toDouble() ?? 0,
      freeShippingMinSubtotalLak:
          (json['free_shipping_min_subtotal_lak'] as num?)?.toDouble() ?? 0,
      bcelQrEnabled: json['bcel_qr_enabled'] as bool? ?? true,
      codEnabled: json['cod_enabled'] as bool? ?? true,
    );
  }
}
