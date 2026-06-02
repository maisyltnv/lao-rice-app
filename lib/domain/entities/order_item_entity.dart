import '../../core/utils/lak_amount.dart';

class OrderItemEntity {
  const OrderItemEntity({
    required this.productName,
    required this.quantity,
    required this.unitPriceLak,
    required this.lineTotalLak,
  });

  final String productName;
  final int quantity;
  final double unitPriceLak;
  final double lineTotalLak;

  factory OrderItemEntity.fromJson(Map<String, dynamic> j) {
    return OrderItemEntity(
      productName: j['product_name'] as String? ?? '',
      quantity: (j['quantity'] as num?)?.toInt() ?? 0,
      unitPriceLak: LakAmount.normalize(j['unit_price_lak'] as num?),
      lineTotalLak: LakAmount.normalize(j['line_total_lak'] as num?),
    );
  }
}
