import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants/vientiane_delivery.dart';
import '../../core/theme/app_colors.dart';

/// Pauses ancestor [Scrollable] only when the user drags on the map (not on tap).
class _MapScrollHold extends StatefulWidget {
  const _MapScrollHold({required this.child});

  final Widget child;

  @override
  State<_MapScrollHold> createState() => _MapScrollHoldState();
}

class _MapScrollHoldState extends State<_MapScrollHold> {
  static const _dragSlop = 10.0;

  ScrollHoldController? _hold;
  Offset? _pointerDown;

  void _beginHold() {
    if (_hold != null) return;
    final position = Scrollable.maybeOf(context)?.position;
    if (position == null) return;
    _hold = position.hold(() {});
  }

  void _endHold() {
    _hold?.cancel();
    _hold = null;
  }

  @override
  void dispose() {
    _endHold();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (e) => _pointerDown = e.position,
      onPointerMove: (e) {
        final start = _pointerDown;
        if (start == null) return;
        if ((e.position - start).distance > _dragSlop) {
          _beginHold();
        }
      },
      onPointerUp: (_) {
        _pointerDown = null;
        _endHold();
      },
      onPointerCancel: (_) {
        _pointerDown = null;
        _endHold();
      },
      child: widget.child,
    );
  }
}

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
  static const _mapHeight = 260.0;
  static const _defaultZoom = 14.0;
  static const _gpsZoom = 16.0;
  static const _minZoom = 11.0;
  static const _maxZoom = 18.0;

  final _mapController = MapController();
  bool _locating = false;
  String? _error;
  String? _hint;

  late double _pinLat;
  late double _pinLng;

  @override
  void initState() {
    super.initState();
    _syncPinFromWidget();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.latitude == null || widget.longitude == null) {
        widget.onChanged(_pinLat, _pinLng);
      }
    });
  }

  void _syncPinFromWidget() {
    _pinLat = widget.latitude ?? VientianeDelivery.centerLat;
    _pinLng = widget.longitude ?? VientianeDelivery.centerLng;
  }

  @override
  void didUpdateWidget(DeliveryLocationPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.latitude != oldWidget.latitude ||
        widget.longitude != oldWidget.longitude) {
      setState(_syncPinFromWidget);
      _moveMapTo(_pinLat, _pinLng, zoom: _defaultZoom);
    }
  }

  void _moveMapTo(double lat, double lng, {required double zoom}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _mapController.move(LatLng(lat, lng), zoom.clamp(_minZoom, _maxZoom));
    });
  }

  void _zoomBy(double delta) {
    final camera = _mapController.camera;
    final next = (camera.zoom + delta).clamp(_minZoom, _maxZoom);
    _mapController.move(camera.center, next);
  }

  void _applyCoordinates(double lat, double lng, {required String hint}) {
    if (!VientianeDelivery.contains(lat, lng)) {
      setState(() {
        _error = 'ຈຸດສົ່ງຕ້ອງຢູ່ພາຍໃນນະຄອນຫຼວງວຽງຈັນ';
        _hint = null;
      });
      return;
    }
    setState(() {
      _error = null;
      _hint = hint;
      _pinLat = lat;
      _pinLng = lng;
    });
    widget.onChanged(lat, lng);
  }

  void _pinFromMapTap(LatLng point) {
    _applyCoordinates(
      point.latitude,
      point.longitude,
      hint: 'ປັກຫມຸດແລ້ວ — ກົດໃນແຜນທີ່ເພື່ອປ່ຽນຈຸດ',
    );
  }

  void _pinFromMapCenter() {
    final center = _mapController.camera.center;
    _applyCoordinates(
      center.latitude,
      center.longitude,
      hint: 'ປັກຫມຸດຕາມຈຸດກາງແຜນທີ່ແລ້ວ',
    );
  }

  void _onMapEvent(MapEvent event) {
    if (event is MapEventTap) {
      _pinFromMapTap(event.tapPosition);
    }
  }

  Future<bool> _confirmOpenSettings({
    required String title,
    required String message,
  }) async {
    if (!mounted) return false;
    final open = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: GoogleFonts.notoSansLao(fontWeight: FontWeight.w700)),
        content: Text(message, style: GoogleFonts.notoSansLao(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('ຍົກເລີກ', style: GoogleFonts.notoSansLao()),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: Text('ເປີດການຕັ້ງຄ່າ', style: GoogleFonts.notoSansLao()),
          ),
        ],
      ),
    );
    return open == true;
  }

  Future<bool> _ensureLocationReady() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (!mounted) return false;
      final open = await _confirmOpenSettings(
        title: 'ເປີດ GPS',
        message:
            'ກະລຸນາເປີດບໍລິການຕຳແໜ່ງ (GPS) ໃນການຕັ້ງຄ່າ ແລ້ວກົດ «ໃຊ້ຕຳແໜ່ງຂອງຂ້ອຍ» ອີກຄັ້ງ',
      );
      if (open) await Geolocator.openLocationSettings();
      if (mounted) setState(() => _error = 'ກະລຸນາເປີດ GPS ໃນການຕັ້ງຄ່າ');
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      if (!mounted) return false;
      final open = await _confirmOpenSettings(
        title: 'ອະນຸຍາດຕຳແໜ່ງ',
        message:
            'ແອັບຕ້ອງໃຊ້ຕຳແໜ່ງເພື່ອປັກຫມຸດສົ່ງໃຫ້ — ກະລຸນາອະນຸຍາດໃນ Settings',
      );
      if (open) await Geolocator.openAppSettings();
      if (mounted) {
        setState(() => _error = 'ກະລຸນາອະນຸຍາດໃຫ້ໃຊ້ຕຳແໜ່ງໃນການຕັ້ງຄ່າ');
      }
      return false;
    }

    if (permission == LocationPermission.denied) {
      if (mounted) setState(() => _error = 'ກະລຸນາກົດ «ອະນຸຍາດ» ເມື່ອລະບົບຖາມ');
      return false;
    }

    return true;
  }

  Future<Position?> _readCurrentPosition() async {
    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
    } catch (_) {
      return Geolocator.getLastKnownPosition();
    }
  }

  Future<void> _useMyLocation() async {
    setState(() {
      _locating = true;
      _error = null;
      _hint = null;
    });

    try {
      if (!await _ensureLocationReady()) return;

      final pos = await _readCurrentPosition();
      if (pos == null) {
        if (mounted) setState(() => _error = 'ບໍ່ສາມາດອ່ານຕຳແໜ່ງໄດ້ — ລອງອີກຄັ້ງ');
        return;
      }

      if (!mounted) return;
      _applyCoordinates(
        pos.latitude,
        pos.longitude,
        hint: 'ປັກຫມຸດຕາມ GPS ແລ້ວ',
      );
      _mapController.move(LatLng(pos.latitude, pos.longitude), _gpsZoom);
    } catch (_) {
      if (mounted) setState(() => _error = 'ບໍ່ສາມາດອ່ານຕຳແໜ່ງໄດ້');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pin = LatLng(_pinLat, _pinLng);
    const mapFlags = InteractiveFlag.all &
        ~InteractiveFlag.rotate &
        ~InteractiveFlag.doubleTapZoom;

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
            '① ກົດໃນແຜນທີ່ ② ປັກຈຸດກາງແຜນທີ່ ③ ໃຊ້ຕຳແໜ່ງຂອງຂ້ອຍ (GPS)',
            style: GoogleFonts.notoSansLao(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: _locating ? null : _useMyLocation,
                  icon: _locating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.my_location_rounded, size: 18),
                  label: Text(
                    'ໃຊ້ຕຳແໜ່ງຂອງຂ້ອຍ',
                    style: GoogleFonts.notoSansLao(fontSize: 13),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: _pinFromMapCenter,
                icon: const Icon(Icons.add_location_alt_outlined, size: 18),
                label: Text(
                  'ປັກຈຸດກາງ',
                  style: GoogleFonts.notoSansLao(fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: _mapHeight,
              width: double.infinity,
              child: _MapScrollHold(
                child: Stack(
                  children: [
                    FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: pin,
                        initialZoom: _defaultZoom,
                        minZoom: _minZoom,
                        maxZoom: _maxZoom,
                        onTap: (_, point) => _pinFromMapTap(point),
                        onMapEvent: _onMapEvent,
                        interactionOptions: const InteractionOptions(flags: mapFlags),
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.lao_rice_shop.app',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: pin,
                              width: 42,
                              height: 42,
                              alignment: Alignment.bottomCenter,
                              child: IgnorePointer(
                                child: Icon(
                                  Icons.location_on,
                                  color: AppColors.error,
                                  size: 42,
                                  shadows: const [
                                    Shadow(
                                      blurRadius: 4,
                                      color: Color(0x44000000),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Column(
                        children: [
                          _ZoomButton(icon: Icons.add, onPressed: () => _zoomBy(1)),
                          const SizedBox(height: 4),
                          _ZoomButton(icon: Icons.remove, onPressed: () => _zoomBy(-1)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ພິກັດ: ${_pinLat.toStringAsFixed(5)}, ${_pinLng.toStringAsFixed(5)}',
            style: GoogleFonts.robotoMono(fontSize: 12, color: AppColors.textSecondary),
          ),
          if (_hint != null) ...[
            const SizedBox(height: 6),
            Text(
              _hint!,
              style: GoogleFonts.notoSansLao(fontSize: 12, color: AppColors.primary),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 6),
            Text(_error!, style: GoogleFonts.notoSansLao(fontSize: 12, color: AppColors.error)),
          ],
        ],
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  const _ZoomButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Icon(icon, size: 20, color: AppColors.primary),
        ),
      ),
    );
  }
}
