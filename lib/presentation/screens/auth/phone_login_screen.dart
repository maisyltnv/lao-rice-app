import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../core/navigation/post_login_navigation.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/datasources/remote/api_service.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/brand_logo.dart';
import '../../widgets/top_right_toast.dart';

/// Phone + OTP login before checkout. Stub OTP: **1234**.
class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({
    super.key,
    this.onSuccess,
    this.embedded = false,
    this.loginSubtitle,
  });

  /// Override post-login navigation; otherwise uses [navigateAfterPhoneLogin].
  final VoidCallback? onSuccess;

  /// When true, omits [Scaffold]/[AppBar] (e.g. inside bottom-nav Orders tab).
  final bool embedded;

  final String? loginSubtitle;

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  bool _otpSent = false;
  bool _busy = false;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendOtp() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.length < 8) {
      showTopRightToast(context, 'ກະລຸນາໃສ່ເບີໂທລະສັບຢ່າງໜ້ອຍ 8 ຕົວ');
      return;
    }
    setState(() => _busy = true);
    try {
      await context.read<AuthProvider>().sendPhoneOtp(phone);
      if (!mounted) return;
      setState(() {
        _otpSent = true;
        _otpCtrl.clear();
      });
      showTopRightToast(context, 'ສົ່ງລະຫັດ OTP ແລ້ວ (ທົດລອງ: 1234)');
    } catch (e) {
      if (!mounted) return;
      final msg = e is ApiException ? (e.messageOrBody) : 'ສົ່ງ OTP ບໍ່ສຳເລັດ';
      showTopRightToast(context, msg, isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _verify() async {
    final phone = _phoneCtrl.text.trim();
    final code = _otpCtrl.text.trim();
    if (code.length < 4) {
      showTopRightToast(context, 'ກະລຸນາໃສ່ລະຫັດ OTP 4 ຕົວ');
      return;
    }
    setState(() => _busy = true);
    try {
      await context.read<AuthProvider>().loginWithPhoneOtp(phone, code);
      if (!mounted) return;
      navigateAfterPhoneLogin(context, onSuccess: widget.onSuccess);
    } catch (e) {
      if (!mounted) return;
      final msg = e is ApiException ? (e.messageOrBody) : 'ລະຫັດ OTP ບໍ່ຖືກຕ້ອງ';
      showTopRightToast(context, msg, isError: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Widget _buildBody() {
    final subtitle = widget.loginSubtitle ??
        (widget.embedded ? 'ຕ້ອງເຂົ້າລະບົບເພື່ອເບິ່ງຄຳສັ່ງຊື້' : 'ຕ້ອງເຂົ້າລະບົບກ່ອນສັ່ງຊື້');

    return ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Row(
            children: [
              const BrandLogo(size: 48, showShadow: true),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ເຂົ້າລະບົບດ້ວຍເບີໂທ',
                      style: GoogleFonts.notoSansLao(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.notoSansLao(fontSize: 13, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('ເບີໂທລະສັບ', style: GoogleFonts.notoSansLao(fontWeight: FontWeight.w600)),
          const SizedBox(height: AppSpacing.sm),
          TextField(
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            enabled: !_otpSent && !_busy,
            decoration: const InputDecoration(
              hintText: '020 1234 5678',
              prefixIcon: Icon(Icons.phone_rounded),
            ),
          ),
          if (_otpSent) ...[
            const SizedBox(height: AppSpacing.lg),
            Text('ລະຫັດ OTP', style: GoogleFonts.notoSansLao(fontWeight: FontWeight.w600)),
            const SizedBox(height: AppSpacing.sm),
            TextField(
              controller: _otpCtrl,
              keyboardType: TextInputType.number,
              maxLength: 4,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: const InputDecoration(
                hintText: '1234',
                counterText: '',
                prefixIcon: Icon(Icons.lock_outline_rounded),
              ),
              onSubmitted: (_) => _verify(),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          FilledButton(
            onPressed: _busy ? null : (_otpSent ? _verify : _sendOtp),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(48),
              backgroundColor: AppColors.primary,
            ),
            child: Text(
              _busy
                  ? 'ກຳລັງດຳເນີນການ...'
                  : (_otpSent ? 'ຢືນຢັນ ແລະ ເຂົ້າລະບົບ' : 'ສົ່ງລະຫັດ OTP'),
              style: GoogleFonts.notoSansLao(fontWeight: FontWeight.w700),
            ),
          ),
          if (_otpSent)
            TextButton(
              onPressed: _busy
                  ? null
                  : () => setState(() {
                        _otpSent = false;
                        _otpCtrl.clear();
                      }),
              child: Text('ປ່ຽນເບີໂທ', style: GoogleFonts.notoSansLao()),
            ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'ທົດລອງ: ໃຊ້ລະຫັດ 1234 (ຈົນກວ່າ SMS API ພ້ອມ)',
            textAlign: TextAlign.center,
            style: GoogleFonts.notoSansLao(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      );
  }

  @override
  Widget build(BuildContext context) {
    final body = _buildBody();
    if (widget.embedded) {
      return body;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('ເຂົ້າລະບົບ', style: GoogleFonts.notoSansLao(fontWeight: FontWeight.w700)),
      ),
      body: body,
    );
  }
}
