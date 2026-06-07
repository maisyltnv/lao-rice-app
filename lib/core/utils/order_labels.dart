import 'package:intl/intl.dart';

/// Lao labels for order status and payment (customer-facing).
String orderStatusLabelLao(String status) {
  final s = status.toLowerCase();
  if (s.contains('processing') || s.contains('confirm')) {
    return 'ກຳລັງດຳເນີນ';
  }
  if (s.contains('shipped') || s.contains('shipping')) {
    return 'ສົ່ງແລ້ວ';
  }
  if (s.contains('delivered') || s.contains('completed') || s.contains('done')) {
    return 'ສຳເລັດ';
  }
  return 'ລໍຖ້າ';
}

String orderPaymentLabelLao(String method) {
  if (method == 'bcel_qr') return 'BCEL One QR';
  if (method == 'cod') return 'ເກັບເງິນປາຍທາງ (COD)';
  if (method.isEmpty) return '—';
  return method;
}

/// Safe date for order cards (avoids LocaleDataException if intl data not loaded).
String formatOrderDateLao(DateTime? dt) {
  if (dt == null) return '—';
  final local = dt.toLocal();
  try {
    return DateFormat.yMMMd('lo_LA').format(local);
  } catch (_) {
    final d = local.day.toString().padLeft(2, '0');
    final m = local.month.toString().padLeft(2, '0');
    return '$d/$m/${local.year}';
  }
}
