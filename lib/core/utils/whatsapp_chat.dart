import 'package:url_launcher/url_launcher.dart';

import '../constants/support_contact_config.dart';

/// Opens WhatsApp (or WhatsApp Business) with a pre-filled message.
Future<bool> openWhatsAppChat({String? message}) async {
  final phone = SupportContactConfig.whatsAppE164;
  final text = (message ?? SupportContactConfig.defaultGreeting).trim();
  final uri = Uri.https(
    'wa.me',
    phone,
    text.isEmpty ? null : <String, String>{'text': text},
  );

  if (!await canLaunchUrl(uri)) {
    return false;
  }
  return launchUrl(uri, mode: LaunchMode.externalApplication);
}
