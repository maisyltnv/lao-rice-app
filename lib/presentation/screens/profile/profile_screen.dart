import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/api_config.dart';
import '../../widgets/brand_logo.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/datasources/remote/api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool? _apiOk;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _ping());
  }

  Future<void> _ping() async {
    final ok = await context.read<ApiService>().pingHealth();
    if (mounted) setState(() => _apiOk = ok);
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.lg),
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            gradient: AppColors.heroGradient,
            borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              const BrandLogo(size: 56),
              const SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lao Beauty & Health',
                      style: GoogleFonts.notoSansLao(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'ຮ້ານສຸຂະພາບ & ຄວາມງາມ',
                      style: GoogleFonts.notoSansLao(color: Colors.white.withValues(alpha: 0.9), fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _InfoCard(
          title: 'ການເຊື່ອມຕໍ່ API',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(ApiConfig.baseUrl, style: GoogleFonts.notoSansLao(fontSize: 13, color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Icon(
                    _apiOk == true ? Icons.check_circle_rounded : Icons.error_outline_rounded,
                    size: 20,
                    color: _apiOk == true ? AppColors.success : AppColors.error,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _apiOk == null ? 'ກຳລັງກວດສອບ...' : (_apiOk! ? 'ເຊື່ອມຕໍ່ສຳເລັດ' : 'ເຊື່ອມຕໍ່ບໍ່ໄດ້'),
                    style: GoogleFonts.notoSansLao(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  TextButton(onPressed: _ping, child: const Text('ກວດຄືນ')),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _InfoCard(
          title: 'ວິທີໃຊ້ງານ',
          child: Column(
            children: [
              _StepRow(number: '1', text: 'ເລືອກສິນຄ້າ ແລະ ເພີ່ມໃສ່ກະຕ່າ'),
              _StepRow(number: '2', text: 'ຊຳລະເງິນ — ບໍ່ຕ້ອງເຂົ້າສູ່ລະບົບ'),
              _StepRow(number: '3', text: 'ຕິດຕາມຄຳສັ່ງຊື້ດ້ວຍເບີໂທ'),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GoogleFonts.notoSansLao(fontSize: 15, fontWeight: FontWeight.w700)),
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
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Text(number, style: GoogleFonts.notoSansLao(fontWeight: FontWeight.w700, color: AppColors.primary)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(text, style: GoogleFonts.notoSansLao(fontSize: 14, height: 1.4))),
        ],
      ),
    );
  }
}
