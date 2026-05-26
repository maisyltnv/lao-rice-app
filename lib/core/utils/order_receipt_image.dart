import 'api_media_url.dart';

/// Resolves [payment_receipt_url] from API (relative `/uploads/...` or absolute).
String orderReceiptImageUrl(String? url) => ApiMediaUrl.resolve(url);
