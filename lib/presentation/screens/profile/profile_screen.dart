import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/api_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/datasources/remote/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/brand_logo.dart';
import '../auth/phone_login_screen.dart';
import '../info/delivery_info_screen.dart';
import '../shell/main_shell.dart';
import 'customer_profile_edit_screen.dart';

/// ບັນຊີລູກຄ້າ — ເບີໂທ OTP, ກະຕ່າ, ຈັດສົ່ງ, ເຂົ້າ/ອອກລະບົບ.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static void _openDeliveryInfo(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const DeliveryInfoScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final cart = context.watch<CartProvider>();

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
                      'ຮ້ານເຂົ້າສານ',
                      style: GoogleFonts.notoSansLao(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      auth.isSignedIn ? 'ບັນຊີຂອງຂ້ອຍ' : 'ຍັງບໍ່ໄດ້ເຂົ້າລະບົບ',
                      style: GoogleFonts.notoSansLao(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        if (auth.isSignedIn) ...[
          _InfoCard(
            title: 'ເບີໂທລະສັບ',
            child: Row(
              children: [
                Icon(Icons.phone_rounded, color: AppColors.primary.withValues(alpha: 0.85)),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    auth.phone ?? '—',
                    style: GoogleFonts.notoSansLao(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'ຄຳສັ່ງຊື້ຜູກກັບເບີໂທນີ້ ແລະ ບັນຊີທີ່ເຂົ້າລະບົບດ້ວຍ OTP',
            style: GoogleFonts.notoSansLao(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          _ActionTile(
            icon: Icons.location_on_outlined,
            label: auth.hasSavedShipping
                ? 'ທີ່ຢູ່ຈັດສົ່ງປະຈຳ (ບັນທຶກແລ້ວ)'
                : 'ຕັ້ງທີ່ຢູ່ຈັດສົ່ງປະຈຳ',
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const CustomerProfileEditScreen(),
                ),
              );
            },
          ),
          _ActionTile(
            icon: Icons.shopping_bag_outlined,
            label: 'ກະຕ່າສິນຄ້າ${cart.isEmpty ? '' : ' (${cart.itemCount})'}',
            onTap: () => MainShell.navigateToTab(context, 1),
          ),
          _ActionTile(
            icon: Icons.receipt_long_outlined,
            label: 'ຄຳສັ່ງຊື້ຂອງຂ້ອຍ',
            onTap: () => MainShell.navigateToTab(context, 2),
          ),
          _ActionTile(
            icon: Icons.local_shipping_outlined,
            label: 'ການຈັດສົ່ງ ແລະ ຄ່າສົ່ງ',
            onTap: () => _openDeliveryInfo(context),
          ),
          const SizedBox(height: AppSpacing.md),
          OutlinedButton.icon(
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('ອອກຈາກລະບົບແລ້ວ')),
                );
              }
            },
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            label: Text(
              'ອອກຈາກລະບົບ',
              style: GoogleFonts.notoSansLao(fontWeight: FontWeight.w600, color: AppColors.error),
            ),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              side: const BorderSide(color: AppColors.error),
            ),
          ),
        ] else ...[
          Text(
            'ເຂົ້າລະບົບດ້ວຍເບີໂທ ເພື່ອສັ່ງຊື້ ແລະ ເບິ່ງຄຳສັ່ງຂອງທ່ານ',
            style: GoogleFonts.notoSansLao(fontSize: 14, color: AppColors.textSecondary),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const PhoneLoginScreen()),
              );
            },
            icon: const Icon(Icons.login_rounded),
            label: Text('ເຂົ້າລະບົບ', style: GoogleFonts.notoSansLao(fontWeight: FontWeight.w700)),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _InfoCard(
            title: 'ວິທີໃຊ້ງານ',
            child: Column(
              children: [
                _StepRow(number: '1', text: 'ເພີ່ມສິນຄ້າໃສ່ກະຕ່າ'),
                _StepRow(number: '2', text: 'ເຂົ້າລະບົບດ້ວຍ OTP ກ່ອນຊຳລະ'),
                _StepRow(number: '3', text: 'ຕິດຕາມຄຳສັ່ງດ້ວຍເບີໂທຂອງທ່ານ'),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          _ActionTile(
            icon: Icons.local_shipping_outlined,
            label: 'ການຈັດສົ່ງ ແລະ ຄ່າສົ່ງ',
            onTap: () => _openDeliveryInfo(context),
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
        _InfoCard(
          title: 'ການເຊື່ອມຕໍ່ API',
          child: _ApiStatusRow(),
        ),
      ],
    );
  }
}

class _ApiStatusRow extends StatefulWidget {
  @override
  State<_ApiStatusRow> createState() => _ApiStatusRowState();
}

class _ApiStatusRowState extends State<_ApiStatusRow> {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SelectableText(
          ApiConfig.baseUrl,
          style: GoogleFonts.notoSansLao(fontSize: 13, color: AppColors.textSecondary),
        ),
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
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(label, style: GoogleFonts.notoSansLao(fontWeight: FontWeight.w600)),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
              ],
            ),
          ),
        ),
      ),
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
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: Text(number, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(text, style: GoogleFonts.notoSansLao(fontSize: 14))),
        ],
      ),
    );
  }
}
