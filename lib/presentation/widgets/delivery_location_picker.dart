import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/vientiane_delivery.dart';
import '../../core/theme/app_colors.dart';

class DeliveryLocationPicker extends StatefulWidget {
  const DeliveryLocationPicker({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.onChanged,
  });

  final double? latitude;
  final double? longitude;
  final void Function(double lat, double lng) onChanged;

  @override
  State<DeliveryLocationPicker> createState() => _DeliveryLocationPickerState();
}

class _DeliveryLocationPickerState extends State<DeliveryLocationPicker> {
  bool _locating = false;
  String? _error;

  Future<void> _useMyLocation() async {
    setState(() {
      _locating = true;
      _error = null;
    });
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() => _error = 'ກະລຸນາອະນຸຍາດໃຫ້ໃຊ້ຕຳແໜ່ງ (GPS)');
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      _apply(pos.latitude, pos.longitude);
    } catch (_) {
      setState(() => _error = 'ບໍ່ສາມາດອ່ານຕຳແໜ່ງໄດ້');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  void _apply(double lat, double lng) {
    if (!VientianeDelivery.contains(lat, lng)) {
      setState(() => _error = 'ຈຸດສົ່ງຕ້ອງຢູ່ພາຍໃນນະຄອນຫຼວງວຽງຈັນ');
      return;
    }
    setState(() => _error = null);
    widget.onChanged(lat, lng);
  }

  Future<void> _openMaps() async {
    final lat = widget.latitude ?? VientianeDelivery.centerLat;
    final lng = widget.longitude ?? VientianeDelivery.centerLng;
    final uri = Uri.parse('https://www.google.com/maps?q=$lat,$lng');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final lat = widget.latitude ?? VientianeDelivery.centerLat;
    final lng = widget.longitude ?? VientianeDelivery.centerLng;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'ຈຸດສົ່ງເຂົ້າ (ນະຄອນຫຼວງວຽງຈັນ)',
            style: GoogleFonts.notoSansLao(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 6),
          Text(
            'ໃຊ້ GPS ເພື່ອໃຫ້ພະນັກງານຮູ້ຈຸດສົ່ງທັນທີ',
            style: GoogleFonts.notoSansLao(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: _locating ? null : _useMyLocation,
                icon: _locating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.my_location_rounded, size: 18),
                label: Text('ໃຊ້ຕຳແໜ່ງຂອງຂ້ອຍ', style: GoogleFonts.notoSansLao(fontSize: 13)),
              ),
              OutlinedButton(
                onPressed: () => _apply(VientianeDelivery.centerLat, VientianeDelivery.centerLng),
                child: Text('ກາງເມືອ', style: GoogleFonts.notoSansLao(fontSize: 13)),
              ),
              OutlinedButton.icon(
                onPressed: _openMaps,
                icon: const Icon(Icons.map_rounded, size: 18),
                label: Text('ເປີດແຜນທີ່', style: GoogleFonts.notoSansLao(fontSize: 13)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'ພິກັດ: ${lat.toStringAsFixed(5)}, ${lng.toStringAsFixed(5)}',
            style: GoogleFonts.robotoMono(fontSize: 12, color: AppColors.textSecondary),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: GoogleFonts.notoSansLao(fontSize: 12, color: AppColors.error)),
          ],
        ],
      ),
    );
  }
}
