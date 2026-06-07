import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../../../data/datasources/remote/api_service.dart';
import '../../../core/constants/vientiane_delivery.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/delivery_location_picker.dart';
import '../../widgets/top_right_toast.dart';

/// ແກ້ໄຂໂປຣໄຟລ໌ລູກຄ້າ — [basicOnly] ສະແດງແຕ່ຊື່ ແລະ ເບີໂທ.
class CustomerProfileEditScreen extends StatefulWidget {
  const CustomerProfileEditScreen({super.key, this.basicOnly = false});

  final bool basicOnly;

  @override
  State<CustomerProfileEditScreen> createState() =>
      _CustomerProfileEditScreenState();
}

class _CustomerProfileEditScreenState extends State<CustomerProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final TextEditingController _address;
  double? _lat;
  double? _lng;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _name = TextEditingController(text: auth.recipientName);
    _phone = TextEditingController(text: auth.phone ?? '');
    _address = TextEditingController(text: auth.addressDetail);
    if (auth.hasDeliveryPin) {
      _lat = auth.deliveryLatitude;
      _lng = auth.deliveryLongitude;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final lat = widget.basicOnly ? auth.deliveryLatitude : _lat;
    final lng = widget.basicOnly ? auth.deliveryLongitude : _lng;

    if (!widget.basicOnly) {
      if (lat == null ||
          lng == null ||
          !VientianeDelivery.contains(lat, lng)) {
        showTopRightToast(
          context,
          'ກະລຸນາເລືອກຈຸດສົ່ງພາຍໃນນະຄອນຫຼວງວຽງຈັນ',
          isError: true,
        );
        return;
      }
    }

    setState(() => _saving = true);
    try {
      await auth.updateCustomerProfile(
            recipientName: _name.text.trim(),
            shippingPhone: _phone.text.trim(),
            addressDetail: widget.basicOnly ? auth.addressDetail : _address.text.trim(),
            deliveryLatitude: lat ?? 0,
            deliveryLongitude: lng ?? 0,
          );
      if (!mounted) return;
      showTopRightToast(
        context,
        widget.basicOnly ? 'ບັນທຶກໂປຣໄຟລ໌ແລ້ວ' : 'ບັນທຶກທີ່ຢູ່ຈັດສົ່ງແລ້ວ',
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      final msg = e is ApiException && e.statusCode == 404
          ? 'API ຍັງບໍ່ອັບເດດ — ຕ້ອງ deploy server ລ່າສຸດ'
          : e.toString().replaceFirst('Exception: ', '').replaceFirst('ApiException(', '');
      showTopRightToast(context, msg, isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final basicOnly = widget.basicOnly;
    final hint = basicOnly
        ? 'ແກ້ໄຂຊື່ ແລະ ເບີໂທທີ່ສະແດງໃນໂປຣໄຟລ໌'
        : auth.hasSavedShipping
            ? 'ຂໍ້ມູນນີ້ຈະເຕີມໃຫ້ອັດຕະໂນມັດຕອນສັ່ງຊື້'
            : 'ບັນທຶກເພື່ອບໍ່ຕ້ອງພິມຊ້ຳ — ຫຼື ຂໍ້ມູນຈາກການສັ່ງຊື້ຈະຖືກບັນທຶກໃຫ້';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          basicOnly ? 'ແກ້ໄຂໂປຣໄຟລ໌' : 'ທີ່ຢູ່ຈັດສົ່ງປະຈຳ',
          style: GoogleFonts.notoSansLao(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          Text(
            hint,
            style: GoogleFonts.notoSansLao(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(
                    labelText: 'ຊື່ຜູ້ຮັບ',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'ກະລຸນາໃສ່ຊື່' : null,
                ),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: basicOnly ? 'ເບີໂທ' : 'ເບີໂທຈັດສົ່ງ',
                    prefixIcon: const Icon(Icons.phone_outlined),
                  ),
                  validator: (v) =>
                      (v == null || v.trim().length < 8) ? 'ເບີໂທບໍ່ຖືກຕ້ອງ' : null,
                ),
                if (!basicOnly) ...[
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _address,
                    decoration: const InputDecoration(
                      labelText: 'ທີ່ຢູ່ / ບ້ານ / ຖະໜົນ',
                      prefixIcon: Icon(Icons.home_outlined),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'ກະລຸນາໃສ່ທີ່ຢູ່' : null,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  DeliveryLocationPicker(
                    latitude: _lat,
                    longitude: _lng,
                    onChanged: (lat, lng) => setState(() {
                      _lat = lat;
                      _lng = lng;
                    }),
                  ),
                ],
                const SizedBox(height: AppSpacing.xl),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(
                    basicOnly ? 'ບັນທຶກໂປຣໄຟລ໌' : 'ບັນທຶກທີ່ຢູ່ຈັດສົ່ງ',
                    style: GoogleFonts.notoSansLao(fontWeight: FontWeight.w700),
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(48),
                    backgroundColor: AppColors.primary,
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
