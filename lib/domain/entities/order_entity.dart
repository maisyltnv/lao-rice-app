import 'order_item_entity.dart';
import '../../core/utils/lak_amount.dart';

class OrderEntity {
  const OrderEntity({
    required this.id,
    required this.orderNumber,
    required this.totalAmountLak,
    required this.subtotalLak,
    required this.shippingFeeLak,
    required this.status,
    required this.paymentMethod,
    required this.paymentReceiptUrl,
    required this.phone,
    required this.recipientName,
    required this.province,
    required this.addressDetail,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.items,
  });

  final int id;
  final String orderNumber;
  final double totalAmountLak;
  final double subtotalLak;
  final double shippingFeeLak;
  final String status;
  final String paymentMethod;
  final String paymentReceiptUrl;
  final String phone;
  final String recipientName;
  final String province;
  final String addressDetail;
  final double latitude;
  final double longitude;
  final DateTime? createdAt;
  final List<OrderItemEntity> items;

  factory OrderEntity.fromJson(Map<String, dynamic> j) {
    DateTime? created;
    final raw = j['created_at'];
    if (raw is String) {
      created = DateTime.tryParse(raw);
    }
    final rawItems = j['items'] as List<dynamic>? ?? const [];
    return OrderEntity(
      id: (j['id'] as num).toInt(),
      orderNumber: j['order_number'] as String? ?? '#${j['id']}',
      totalAmountLak: LakAmount.normalize(j['total_amount_lak'] as num?),
      subtotalLak: LakAmount.normalize(j['subtotal_lak'] as num?),
      shippingFeeLak: LakAmount.normalize(j['shipping_fee_lak'] as num?),
      status: j['status'] as String? ?? '',
      paymentMethod: j['payment_method'] as String? ?? '',
      paymentReceiptUrl: j['payment_receipt_url'] as String? ?? '',
      phone: j['phone'] as String? ?? '',
      recipientName: j['recipient_name'] as String? ?? '',
      province: j['province'] as String? ?? '',
      addressDetail: j['address_detail'] as String? ?? '',
      latitude: (j['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (j['longitude'] as num?)?.toDouble() ?? 0,
      createdAt: created,
      items: rawItems.map((e) => OrderItemEntity.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
