class AuthUserEntity {
  const AuthUserEntity({
    required this.id,
    required this.username,
    required this.role,
    this.phone,
    this.recipientName = '',
    this.shippingPhone = '',
    this.province = '',
    this.addressDetail = '',
    this.deliveryLatitude = 0,
    this.deliveryLongitude = 0,
  });

  final int id;
  final String username;
  final String role;
  final String? phone;
  final String recipientName;
  final String shippingPhone;
  final String province;
  final String addressDetail;
  final double deliveryLatitude;
  final double deliveryLongitude;

  String get displayPhone {
    final sp = shippingPhone.trim();
    if (sp.isNotEmpty) return sp;
    final p = phone?.trim() ?? '';
    if (p.isNotEmpty) return p;
    return username.trim();
  }

  bool get hasSavedShipping =>
      recipientName.trim().isNotEmpty && addressDetail.trim().isNotEmpty;

  bool get hasDeliveryPin =>
      deliveryLatitude != 0 && deliveryLongitude != 0;

  factory AuthUserEntity.fromJson(Map<String, dynamic> j) {
    double readDouble(dynamic v) {
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v) ?? 0;
      return 0;
    }

    return AuthUserEntity(
      id: (j['id'] as num).toInt(),
      username: j['username'] as String? ?? '',
      role: j['role'] as String? ?? 'user',
      phone: j['phone'] as String?,
      recipientName: j['recipient_name'] as String? ?? '',
      shippingPhone: j['shipping_phone'] as String? ?? '',
      province: j['province'] as String? ?? '',
      addressDetail: j['address_detail'] as String? ?? '',
      deliveryLatitude: readDouble(j['delivery_latitude']),
      deliveryLongitude: readDouble(j['delivery_longitude']),
    );
  }
}
