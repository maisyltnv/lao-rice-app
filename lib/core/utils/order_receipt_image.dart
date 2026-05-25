import '../constants/api_config.dart';

/// Resolves [payment_receipt_url] from API (relative `/uploads/...` or absolute).
String orderReceiptImageUrl(String? url) {
  final trimmed = url?.trim() ?? '';
  if (trimmed.isEmpty) return '';
  if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
    return trimmed;
  }
  final base = ApiConfig.baseUrl;
  final path = trimmed.startsWith('/') ? trimmed : '/$trimmed';
  return '$base$path';
}
