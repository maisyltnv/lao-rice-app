/// WhatsApp Business contact for customer support.
///
/// Override at build time:
/// ```bash
/// flutter run --dart-define=WHATSAPP_NUMBER=8562012345678
/// ```
library;

class SupportContactConfig {
  SupportContactConfig._();

  /// E.164 digits only (no +). Laos mobile example: 85620XXXXXXXX.
  static const String defaultWhatsAppE164 = '8562055512345';

  static const String defaultGreeting =
      'ສະບາຍດີ, ຂ້ອຍສົນໃຈສັ່ງເຂົ້າຈາກຮ້ານເຂົ້າສານ — ຊ່ວຍແນະນຳແລະຢືນຢັນຄຳສັ່ງໃຫ້ແດ່.';

  static String get whatsAppE164 {
    const override = String.fromEnvironment('WHATSAPP_NUMBER');
    if (override.isNotEmpty) return normalizeForWaMe(override);
    return defaultWhatsAppE164;
  }

  /// Converts 020…, +856…, or 856… to wa.me format (85620…).
  static String normalizeForWaMe(String input) {
    var digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) {
      digits = '856${digits.substring(1)}';
    } else if (!digits.startsWith('856')) {
      digits = '856$digits';
    }
    return digits;
  }
}
