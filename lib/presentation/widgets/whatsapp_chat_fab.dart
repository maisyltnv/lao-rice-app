import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../core/constants/support_contact_config.dart';
import '../../core/utils/whatsapp_chat.dart';
import '../providers/auth_provider.dart';
import 'top_right_toast.dart';

/// Top-right chat chip — opens WhatsApp with a greeting prefilled.
class WhatsAppChatFab extends StatelessWidget {
  const WhatsAppChatFab({super.key});

  String _greeting(BuildContext context) {
    final auth = context.read<AuthProvider>();
    if (!auth.isSignedIn) return SupportContactConfig.defaultGreeting;

    final parts = <String>['ສະບາຍດີ, ຂ້ອຍສົນໃຈສັ່ງເຂົ້າຈາກຮ້ານເຂົ້າສານ'];
    final phone = auth.phone?.trim();
    if (phone != null && phone.isNotEmpty) {
      parts.add('ເບີ: $phone');
    }
    parts.add('ຊ່ວຍແນະນຳແລະຢືນຢັນຄຳສັ່ງໃຫ້ແດ່.');
    return parts.join(' — ');
  }

  Future<void> _onTap(BuildContext context) async {
    final ok = await openWhatsAppChat(message: _greeting(context));
    if (!context.mounted) return;
    if (!ok) {
      showTopRightToast(
        context,
        'ບໍ່ສາມາດເປີດ WhatsApp ໄດ້ — ກະລຸນາຕິດຕັ້ງແອັບ WhatsApp',
        isError: true,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      shadowColor: Colors.black26,
      color: const Color(0xFF25D366),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: () => _onTap(context),
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.chat_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 6),
              Text(
                'ແຊັດ',
                style: GoogleFonts.notoSansLao(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
