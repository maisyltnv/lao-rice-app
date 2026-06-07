/// Maps API checkout errors to Lao messages for customers.
String friendlyCheckoutError(String? raw) {
  if (raw == null || raw.trim().isEmpty) return 'ສັ່ງຊື້ບໍ່ສຳເລັດ';
  final lower = raw.toLowerCase();
  if (lower.contains('cod payment is disabled')) {
    return 'ຮ້ານປິດການຈ່າຍ COD ຊົ່ວຄາວ — ກະລຸນາເລືອກວິທີຊຳລະອື່ນ';
  }
  if (lower.contains('bcel_qr payment is disabled')) {
    return 'ຮ້ານປິດການຊຳລະ BCEL QR ຊົ່ວຄາວ — ກະລຸນາເລືອກວິທີຊຳລະອື່ນ';
  }
  return raw;
}
