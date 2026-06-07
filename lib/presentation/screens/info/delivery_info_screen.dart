import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/vientiane_delivery.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/lak_currency_formatter.dart';
import '../../../data/datasources/remote/api_service.dart';
import '../../widgets/brand_logo.dart';
import '../shell/main_shell.dart';

/// ຂໍ້ມູນການຈັດສົ່ງ — ຄ່າສົ່ງ, ເຂດ, ຂັ້ນຕອນ, FAQ (ຄືແອັບຊື້ອອນລາຍທົ່ວໄປ).
class DeliveryInfoScreen extends StatefulWidget {
  const DeliveryInfoScreen({super.key});

  @override
  State<DeliveryInfoScreen> createState() => _DeliveryInfoScreenState();
}

class _DeliveryInfoScreenState extends State<DeliveryInfoScreen> {
  bool _loading = true;
  double? _shippingFeeLak;
  double? _freeMinLak;
  bool _bcelQrEnabled = true;
  bool _codEnabled = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadConfig());
  }

  Future<void> _loadConfig() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final config = await context.read<ApiService>().fetchShippingConfig();
      if (!mounted) return;
      setState(() {
        _shippingFeeLak = config.shippingFeeLak;
        _freeMinLak = config.freeShippingMinSubtotalLak;
        _bcelQrEnabled = config.bcelQrEnabled;
        _codEnabled = config.codEnabled;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = e.toString();
        _shippingFeeLak = 30_000;
        _freeMinLak = 500_000;
        _loading = false;
      });
    }
  }

  void _goToTab(BuildContext context, int index) {
    Navigator.of(context).pop();
    MainShell.navigateToTab(context, index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'ການຈັດສົ່ງ',
          style: GoogleFonts.notoSansLao(fontWeight: FontWeight.w700),
        ),
        backgroundColor: AppColors.background,
      ),
      body: RefreshIndicator(
        color: AppColors.primary,
        onRefresh: _loadConfig,
        child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const Center(child: BrandLogo(size: 56)),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'ການຈັດສົ່ງເຂົ້າຖຶງບ້ານ',
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSansLao(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'ພວກເຮົາຈັດສົ່ງພາຍໃນ${VientianeDelivery.provinceName} ເທົ່ານັ້ນ — ເລືອກຈຸດສົ່ງດ້ວຍແຜນທີ່ GPS ຕອນສັ່ງຊື້',
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSansLao(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          _SectionCard(
            title: 'ຄ່າຈັດສົ່ງ',
            icon: Icons.local_shipping_outlined,
            child: _loading
                ? const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _feeRow(
                        'ຄ່າສົ່ງມາດຕະຖານ',
                        formatLakWeb(_shippingFeeLak ?? 30_000),
                      ),
                      _feeRow(
                        'ສົ່ງຟຣີ',
                        'ຍອດສິນຄ້າຕັ້ງແຕ່ ${formatLakWeb(_freeMinLak ?? 500_000)}',
                      ),
                      if (_loadError != null) ...[
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'ໃຊ້ຄ່າປະມານ — ໂຫຼດຈາກເຊີບເວີບໍ່ສຳເລັດ',
                          style: GoogleFonts.notoSansLao(
                            fontSize: 11,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'ຄ່າສົ່ງຄິດໃນຂັ້ນຕອນຊຳລະເງິນ ຕາມຍອດກະຕ່າຂອງທ່ານ',
                        style: GoogleFonts.notoSansLao(
                          fontSize: 12,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ),
          ),
          const SizedBox(height: AppSpacing.md),
          _SectionCard(
            title: 'ເວລາຈັດສົ່ງໂດຍປະມານ',
            icon: Icons.schedule_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _bullet('ຫຼັງຢືນຢັນຄຳສັ່ງ · ປົກກະຕິ 1–2 ວັນທຳການ'),
                _bullet('ວັນພັກລັດຖະການ ຫຼື ຝົນຕົກອາດຊ້າກວ່າປົກກະຕິ'),
                _bullet('ຕິດຕາມສະຖານະໄດ້ໃນແທັບ «ຄຳສັ່ງຊື້»'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _SectionCard(
            title: 'ຂັ້ນຕອນສັ່ງ ແລະ ຮັບເຄື່ອງ',
            icon: Icons.route_outlined,
            child: const Column(
              children: [
                _StepRow(number: '1', text: 'ເລືອກສິນຄ້າ ແລະ ເພີ່ມໃສ່ກະຕ່າ'),
                _StepRow(number: '2', text: 'ເຂົ້າລະບົບ OTP ແລະ ກົດຊຳລະເງິນ'),
                _StepRow(
                  number: '3',
                  text: 'ປ້ອນທີ່ຢູ່ ແລະ ປັກຫມຸດ GPS ຢູ່ໃນນະຄອນຫຼວງວຽງຈັນ',
                ),
                _StepRow(number: '4', text: 'ຮ້ານຈັດສົ່ງເຂົ້າຈຸດທີ່ທ່ານເລືອກ'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _SectionCard(
            title: 'ເຂດບໍລິການ',
            icon: Icons.map_outlined,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _infoTile(
                  Icons.location_city_outlined,
                  'ພື້ນທີ່',
                  VientianeDelivery.provinceName,
                ),
                _infoTile(
                  Icons.my_location_rounded,
                  'GPS ຕອນສັ່ງ',
                  'ກົດ «ໃຊ້ຕຳແໜ່ງຂອງຂ້ອຍ» ຫຼື ລາກແຜນທີ່ໃນຂັ້ນຕອນຊຳລະ',
                ),
                _infoTile(
                  Icons.block_outlined,
                  'ນອກເຂດ',
                  'ບໍ່ຮັບສົ່ງແຂວງອື່ນ — ກະລຸນາເລືອກຈຸດຢູ່ໃນນະຄອນຫຼວງ',
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _SectionCard(
            title: 'ການຊຳລະເງິນ',
            icon: Icons.payments_outlined,
            child: Column(
              children: [
                if (_bcelQrEnabled)
                  _infoTile(Icons.qr_code_2, 'BCEL One QR', 'ອັບໂຫຼດສະລິບການໂອນ'),
                if (_bcelQrEnabled && _codEnabled) const SizedBox(height: AppSpacing.sm),
                if (_codEnabled)
                  _infoTile(Icons.payments_outlined, 'COD', 'ເກັບເງິນປາຍທາງເມື່ອຮັບເຄື່ອງ'),
                if (!_bcelQrEnabled && !_codEnabled)
                  Text(
                    'ຮ້ານປິດການຊຳລະຊົ່ວຄາວ',
                    style: GoogleFonts.notoSansLao(fontSize: 13, color: AppColors.textSecondary),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _SectionCard(
            title: 'ຄຳຖາມທີ່ພົບເລື້ອຍ',
            icon: Icons.help_outline_rounded,
            child: Column(
              children: _faqs
                  .map(
                    (f) => _FaqTile(question: f.$1, answer: f.$2),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          FilledButton.icon(
            onPressed: () => _goToTab(context, 0),
            icon: const Icon(Icons.storefront_outlined),
            label: Text(
              'ເລີ່ມເລືອກສິນຄ້າ',
              style: GoogleFonts.notoSansLao(fontWeight: FontWeight.w700),
            ),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: () => _goToTab(context, 2),
            icon: const Icon(Icons.receipt_long_outlined),
            label: Text(
              'ຕິດຕາມຄຳສັ່ງຊື້',
              style: GoogleFonts.notoSansLao(fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
        ),
      ),
    );
  }

  static const _faqs = <(String, String)>[
    (
      'ຈັດສົ່ງໄປແຂວງອື່ນໄດ້ບໍ?',
      'ຕອນນີ້ຮັບພຽງໃນນະຄອນຫຼວງວຽງຈັນ. ຖ້າຢູ່ນອກເຂດ ລະບົບຈະບໍ່ໃຫ້ຢືນຢັນຄຳສັ່ງ.',
    ),
    (
      'ປ່ຽນທີ່ຢູ່ຈັດສົ່ງໄດ້ບໍ?',
      'ປ້ອນໃໝ່ທຸກຄັ້ງຕອນສັ່ງຊື້. ຖ້າສັ່ງແລ້ວ ຕິດຕໍ່ຮ້ານທາງໂທກ່ອນອອກຈາກຮ້ານ.',
    ),
    (
      'ຄ່າສົ່ງຟຣີເມື່ອໃດ?',
      'ເມື່ອຍອດສິນຄ້າ (ບໍ່ລວມຄ່າສົ່ງ) ຮອດຕາມເງື່ອນໄຂທີ່ສະແດງໃນຂັ້ນຕອນຊຳລະ.',
    ),
    (
      'ຊຳລະ COD ແລ້ວຍົກເລີກໄດ້ບໍ?',
      'ກະລຸນາຕິດຕໍ່ຮ້ານທັນທີ — ສະຖານະຄຳສັ່ງຈະອັບເດດໃນແທັບຄຳສັ່ງຊື້.',
    ),
  ];

  Widget _feeRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.notoSansLao(fontSize: 14, color: AppColors.textSecondary),
          ),
          Text(
            value,
            style: GoogleFonts.notoSansLao(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: AppColors.primary, fontSize: 16)),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.notoSansLao(fontSize: 13, height: 1.45),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _infoTile(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.notoSansLao(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.notoSansLao(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.notoSansLao(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          child,
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(text, style: GoogleFonts.notoSansLao(fontSize: 14, height: 1.4)),
          ),
        ],
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        childrenPadding: const EdgeInsets.only(bottom: AppSpacing.sm),
        iconColor: AppColors.primary,
        collapsedIconColor: AppColors.textMuted,
        title: Text(
          question,
          style: GoogleFonts.notoSansLao(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              answer,
              style: GoogleFonts.notoSansLao(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
