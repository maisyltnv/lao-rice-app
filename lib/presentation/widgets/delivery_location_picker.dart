import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latlong2/latlong.dart';

import '../../core/constants/vientiane_delivery.dart';
import '../../core/theme/app_colors.dart';

const _pinWidth = 32.0;
const _pinHeight = 42.0;

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
  final _mapKey = GlobalKey();
  bool _locating = false;
  String? _error;
  String? _hint;

  late double _pinLat;
  late double _pinLng;
  double? _lastNotifiedLat;
  double? _lastNotifiedLng;

  @override
  void initState() {
    super.initState();
    _syncPinFromWidget();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (widget.latitude == null || widget.longitude == null) {
        _lastNotifiedLat = _pinLat;
        _lastNotifiedLng = _pinLng;
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
    if (widget.latitude == oldWidget.latitude &&
        widget.longitude == oldWidget.longitude) {
      return;
    }

    final echoedFromPicker = _coordsMatch(widget.latitude, _lastNotifiedLat) &&
        _coordsMatch(widget.longitude, _lastNotifiedLng);
    if (echoedFromPicker) return;

    setState(_syncPinFromWidget);
    _moveMapTo(_pinLat, _pinLng, zoom: _defaultZoom);
  }

  bool _coordsMatch(double? a, double? b) {
    if (a == null || b == null) return false;
    return (a - b).abs() < 1e-7;
  }

  void _moveMapTo(double lat, double lng, {double? zoom}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final z = (zoom ?? _mapController.camera.zoom).clamp(_minZoom, _maxZoom);
      _mapController.move(LatLng(lat, lng), z);
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

    _lastNotifiedLat = lat;
    _lastNotifiedLng = lng;
    widget.onChanged(lat, lng);
  }

  LatLng? _latLngFromTap(TapPosition tapPosition) {
    final relative = tapPosition.relative;
    if (relative != null) {
      return _mapController.camera.offsetToCrs(relative);
    }

    final mapBox = _mapKey.currentContext?.findRenderObject() as RenderBox?;
    if (mapBox == null || !mapBox.hasSize) return null;

    final local = mapBox.globalToLocal(tapPosition.global);
    final mapRect = Offset.zero & mapBox.size;
    if (!mapRect.contains(local)) return null;
    return _mapController.camera.offsetToCrs(local);
  }

  void _pinFromMapTap(TapPosition tapPosition) {
    final point = _latLngFromTap(tapPosition);
    if (point == null) return;
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
      _moveMapTo(pos.latitude, pos.longitude, zoom: _gpsZoom);
    } catch (_) {
      if (mounted) setState(() => _error = 'ບໍ່ສາມາດອ່ານຕຳແໜ່ງໄດ້');
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pin = LatLng(_pinLat, _pinLng);
    final pinAnchor = Marker.computePixelAlignment(
      width: _pinWidth,
      height: _pinHeight,
      left: _pinWidth / 2,
      top: _pinHeight,
    );
    const mapFlags = InteractiveFlag.all &
        ~InteractiveFlag.rotate &
        ~InteractiveFlag.doubleTapZoom &
        ~InteractiveFlag.doubleTapDragZoom;

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
                      key: _mapKey,
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: pin,
                        initialZoom: _defaultZoom,
                        minZoom: _minZoom,
                        maxZoom: _maxZoom,
                        onTap: (tapPosition, _) => _pinFromMapTap(tapPosition),
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
                              width: _pinWidth,
                              height: _pinHeight,
                              alignment: pinAnchor,
                              child: const IgnorePointer(
                                child: _DeliveryPinMarker(),
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

class _DeliveryPinMarker extends StatelessWidget {
  const _DeliveryPinMarker();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(_pinWidth, _pinHeight),
      painter: _DeliveryPinPainter(color: AppColors.error),
    );
  }
}

class _DeliveryPinPainter extends CustomPainter {
  const _DeliveryPinPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final tip = Offset(w / 2, h);
    final bodyTop = h * 0.08;

    final path = ui.Path()
      ..moveTo(tip.dx, tip.dy)
      ..quadraticBezierTo(w * 0.92, h * 0.62, w * 0.82, bodyTop + w * 0.18)
      ..arcToPoint(
        Offset(w * 0.18, bodyTop + w * 0.18),
        radius: Radius.circular(w * 0.32),
        clockwise: false,
      )
      ..quadraticBezierTo(w * 0.08, h * 0.62, tip.dx, tip.dy)
      ..close();

    canvas.drawShadow(path, const Color(0x66000000), 2.5, false);
    canvas.drawPath(path, Paint()..color = color);
    canvas.drawCircle(
      Offset(w / 2, bodyTop + w * 0.34),
      w * 0.16,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _DeliveryPinPainter oldDelegate) => oldDelegate.color != color;
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
