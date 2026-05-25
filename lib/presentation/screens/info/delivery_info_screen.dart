import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/constants/vientiane_delivery.dart';
import '../../../core/theme/app_colors.dart';

/// Explains Vientiane-only delivery with GPS at checkout.
class DeliveryInfoScreen extends StatelessWidget {
  const DeliveryInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Icon(Icons.rice_bowl_rounded, size: 56, color: AppColors.primary),
        const SizedBox(height: 16),
        Text(
          'ຈັດສົ່ງເຂົ້າສານພາຍໃນນະຄອນຫຼວງວຽງຈັນ',
          style: GoogleFonts.notoSansLao(fontSize: 20, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Text(
          'ເມື່ອສັ່ງຊື້ ກະລຸນາເລືອກຈຸດສົ່ງດ້ວຍ GPS ເພື່ອໃຫ້ພະນັກງານຮູ້ທີ່ຢູ່ທັນທີ',
          style: GoogleFonts.notoSansLao(fontSize: 14, color: AppColors.textSecondary, height: 1.5),
        ),
        const SizedBox(height: 24),
        _tile(Icons.my_location_rounded, 'ໃຊ້ຕຳແໜ່ງຂອງຂ້ອຍ', 'ກົດປຸ່ມໃນຂັ້ນຕອນສັ່ງຊື້'),
        _tile(Icons.map_rounded, 'ເຂດຈັດສົ່ງ', VientianeDelivery.provinceName),
        _tile(Icons.payments_outlined, 'ຊຳລະ', 'BCEL QR ຫຼື ເກັບເງິນປາຍທາງ (COD)'),
      ],
    );
  }

  Widget _tile(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.notoSansLao(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(subtitle, style: GoogleFonts.notoSansLao(fontSize: 13, color: AppColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
