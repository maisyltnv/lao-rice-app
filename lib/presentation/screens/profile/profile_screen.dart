import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/api_config.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/datasources/remote/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/customer_profile_avatar.dart';
import '../../widgets/top_right_toast.dart';
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

    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.lg),
        children: [
          _CustomerProfileHeader(
            isSignedIn: auth.isSignedIn,
            recipientName: auth.recipientName,
            phone: auth.phone,
            localAvatarPath: auth.localAvatarPath,
            onEdit: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const CustomerProfileEditScreen(basicOnly: true),
                ),
              );
            },
          ),
          const SizedBox(height: AppSpacing.lg),
          if (auth.isSignedIn) ...[
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
        const _ApiConnectionWarning(),
      ],
      ),
    );
  }
}

class _CustomerProfileHeader extends StatefulWidget {
  const _CustomerProfileHeader({
    required this.isSignedIn,
    required this.recipientName,
    required this.phone,
    required this.localAvatarPath,
    required this.onEdit,
  });

  final bool isSignedIn;
  final String recipientName;
  final String? phone;
  final String? localAvatarPath;
  final VoidCallback onEdit;

  @override
  State<_CustomerProfileHeader> createState() => _CustomerProfileHeaderState();
}

class _CustomerProfileHeaderState extends State<_CustomerProfileHeader> {
  final _imagePicker = ImagePicker();
  bool _uploading = false;

  String get _displayName => widget.recipientName.trim();

  String get _displayPhone {
    final p = widget.phone?.trim() ?? '';
    return p.isEmpty ? '—' : p;
  }

  Future<void> _showAvatarOptions() async {
    final auth = context.read<AuthProvider>();
    final hasAvatar = auth.localAvatarPath != null;

    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text('ເລືອກຮູບຈາກແກລລີ', style: GoogleFonts.notoSansLao()),
              onTap: () => Navigator.pop(context, 'gallery'),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text('ຖ່າຍຮູບໃໝ່', style: GoogleFonts.notoSansLao()),
              onTap: () => Navigator.pop(context, 'camera'),
            ),
            if (hasAvatar)
              ListTile(
                leading: const Icon(Icons.delete_outline, color: AppColors.error),
                title: Text(
                  'ລຶບຮູບໂປຣໄຟລ໌',
                  style: GoogleFonts.notoSansLao(color: AppColors.error),
                ),
                onTap: () => Navigator.pop(context, 'remove'),
              ),
          ],
        ),
      ),
    );
    if (!mounted || action == null) return;

    if (action == 'remove') {
      await auth.clearLocalAvatar();
      if (!mounted) return;
      showTopRightToast(context, 'ລຶບຮູບໂປຣໄຟລ໌ແລ້ວ');
      return;
    }

    final source = action == 'camera' ? ImageSource.camera : ImageSource.gallery;
    await _pickAndSaveAvatar(source);
  }

  Future<void> _pickAndSaveAvatar(ImageSource source) async {
    setState(() => _uploading = true);
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (picked == null || !mounted) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      final auth = context.read<AuthProvider>();
      await auth.saveLocalAvatar(bytes);
      if (!mounted) return;
      showTopRightToast(context, 'ບັນທຶກຮູບໂປຣໄຟລ໌ແລ້ວ');
    } catch (e) {
      if (!mounted) return;
      showTopRightToast(context, 'ບັນທຶກຮູບບໍ່ສຳເລັດ', isError: true);
    } finally {
      if (mounted) setState(() => _uploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasName = widget.isSignedIn && _displayName.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: AppColors.profileHeaderGradient,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 2),
                ),
                child: CustomerProfileAvatar(
                  radius: 34,
                  isSignedIn: widget.isSignedIn,
                  displayName: _displayName.isNotEmpty ? _displayName : _displayPhone,
                  localPath: widget.localAvatarPath,
                  showCameraBadge: widget.isSignedIn,
                  onTap: widget.isSignedIn && !_uploading ? _showAvatarOptions : null,
                ),
              ),
              if (_uploading)
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.35),
                    shape: BoxShape.circle,
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(20),
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.isSignedIn && hasName)
                  Text(
                    _displayName,
                    style: GoogleFonts.notoSansLao(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                    ),
                  )
                else if (widget.isSignedIn)
                  Text(
                    _displayPhone,
                    style: GoogleFonts.notoSansLao(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                else
                  Text(
                    'ຍັງບໍ່ໄດ້ເຂົ້າລະບົບ',
                    style: GoogleFonts.notoSansLao(
                      color: AppColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                const SizedBox(height: 4),
                if (widget.isSignedIn && hasName)
                  Row(
                    children: [
                      Icon(Icons.phone_rounded, size: 14, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          _displayPhone,
                          style: GoogleFonts.notoSansLao(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  )
                else if (widget.isSignedIn)
                  Text(
                    'ລູກຄ້າ',
                    style: GoogleFonts.notoSansLao(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  )
                else
                  Text(
                    'ເຂົ້າລະບົບເພື່ອສັ່ງຊື້ ແລະ ຕິດຕາມຄຳສັ່ງ',
                    style: GoogleFonts.notoSansLao(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
              ],
            ),
          ),
          if (widget.isSignedIn)
            Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Material(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                child: InkWell(
                  onTap: widget.onEdit,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(Icons.edit_outlined, size: 20, color: AppColors.primary),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ApiConnectionWarning extends StatefulWidget {
  const _ApiConnectionWarning();

  @override
  State<_ApiConnectionWarning> createState() => _ApiConnectionWarningState();
}

class _ApiConnectionWarningState extends State<_ApiConnectionWarning> {
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
    if (_apiOk != false) return const SizedBox.shrink();

    return Column(
      children: [
        const SizedBox(height: AppSpacing.lg),
        _InfoCard(
          title: 'ການເຊື່ອມຕໍ່ API',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SelectableText(
                ApiConfig.baseUrl,
                style: GoogleFonts.notoSansLao(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  const Icon(Icons.error_outline_rounded, size: 20, color: AppColors.error),
                  const SizedBox(width: 8),
                  Text(
                    'ເຊື່ອມຕໍ່ບໍ່ໄດ້',
                    style: GoogleFonts.notoSansLao(fontWeight: FontWeight.w600),
                  ),
                  const Spacer(),
                  TextButton(onPressed: _ping, child: const Text('ກວດຄືນ')),
                ],
              ),
            ],
          ),
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
