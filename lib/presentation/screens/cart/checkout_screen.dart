import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/vientiane_delivery.dart';
import '../../widgets/delivery_location_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/checkout_layout.dart';
import '../../providers/cart_provider.dart';
import '../../providers/orders_provider.dart';
import '../../widgets/product_image.dart';
import '../../widgets/top_right_toast.dart';
import 'checkout_widgets.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();

  int _step = 1;
  final _scrollController = ScrollController();
  double? _deliveryLat;
  double? _deliveryLng;
  String _paymentMethod = 'bcel_qr';
  bool _busy = false;
  bool _quoteLoading = true;
  final _imagePicker = ImagePicker();
  XFile? _receiptFile;
  Uint8List? _receiptPreviewBytes;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final orders = context.read<OrdersProvider>();
      final cart = context.read<CartProvider>();
      await orders.loadSavedPhone();
      if (!mounted) return;
      if (orders.phone != null) _phone.text = orders.phone!;
      await orders.refreshShippingQuote(cart.subtotalLak);
      if (mounted) setState(() => _quoteLoading = false);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _name.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  double _totalLak(CartProvider cart, OrdersProvider orders) {
    final quote = orders.shippingQuote;
    if (quote != null) return quote.totalAmountLak;
    return cart.subtotalLak;
  }

  double _shippingFeeLak(OrdersProvider orders) {
    final quote = orders.shippingQuote;
    if (quote != null) return quote.shippingFeeLak;
    return 0;
  }

  bool _validateShipping() {
    if (!_formKey.currentState!.validate()) return false;
    if (_deliveryLat == null ||
        _deliveryLng == null ||
        !VientianeDelivery.contains(_deliveryLat!, _deliveryLng!)) {
      showTopRightToast(
        context,
        'ກະລຸນາເລືອກຈຸດສົ່ງພາຍໃນນະຄອນຫຼວງວຽງຈັນ',
        isError: true,
        duration: const Duration(seconds: 3),
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            0,
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
          );
        }
      });
      return false;
    }
    return true;
  }

  void _goToStep(int step) {
    setState(() => _step = step);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(0);
      }
    });
  }

  Future<void> _pickReceipt() async {
    final picked = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 2048,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;
    final bytes = await picked.readAsBytes();
    if (!mounted) return;
    setState(() {
      _receiptFile = picked;
      _receiptPreviewBytes = bytes;
    });
  }

  void _clearReceipt() {
    setState(() {
      _receiptFile = null;
      _receiptPreviewBytes = null;
    });
  }

  bool _validateReceipt() {
    if (_paymentMethod == 'bcel_qr' && _receiptFile == null) {
      showTopRightToast(
        context,
        'ກະລຸນາອັບໂຫຼດຫຼັກຖານການຊຳລະເງິນ (screenshot BCEL)',
        isError: true,
        duration: const Duration(seconds: 3),
      );
      return false;
    }
    return true;
  }

  Future<void> _submit() async {
    final cart = context.read<CartProvider>();
    if (cart.isEmpty) return;
    if (!_validateReceipt()) return;

    setState(() => _busy = true);
    final orders = context.read<OrdersProvider>();
    List<int>? receiptBytes;
    String? receiptName;
    if (_paymentMethod == 'bcel_qr' && _receiptFile != null) {
      receiptBytes = _receiptPreviewBytes ?? await _receiptFile!.readAsBytes();
      receiptName = _receiptFile!.name;
    }
    final created = await orders.checkout(
      cartItems: cart.items,
      recipientName: _name.text.trim(),
      phone: _phone.text.trim(),
      addressDetail: _address.text.trim(),
      latitude: _deliveryLat!,
      longitude: _deliveryLng!,
      paymentMethod: _paymentMethod,
      paymentReceiptBytes: receiptBytes,
      paymentReceiptFilename: receiptName,
    );
    if (!mounted) return;
    setState(() => _busy = false);

    if (created != null) {
      cart.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ສັ່ງຊື້ສຳເລັດ ${created.orderNumber}')),
      );
      Navigator.of(context).popUntil((route) => route.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(orders.error ?? 'ສັ່ງຊື້ບໍ່ສຳເລັດ')),
      );
    }
  }

  String get _paymentLabel =>
      _paymentMethod == 'bcel_qr' ? 'BCEL One QR Code' : 'ເກັບເງິນປາຍທາງ (COD)';

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final orders = context.watch<OrdersProvider>();

    if (cart.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: const Text('ຊຳລະເງິນ'), backgroundColor: AppColors.background),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ກະຕ່າຂອງທ່ານຫວ່າງເປົ່າ', style: GoogleFonts.notoSansLao(color: AppColors.textSecondary)),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('ກັບໄປເລືອກສິນຄ້າ'),
              ),
            ],
          ),
        ),
      );
    }

    final quote = orders.shippingQuote;
    final subtotal = quote?.subtotalLak ?? cart.subtotalLak;
    final shippingFee = _shippingFeeLak(orders);
    final total = _totalLak(cart, orders);

    final compact = CheckoutLayout.isCompactHeight(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('ຊຳລະເງິນ'),
        backgroundColor: AppColors.background,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CheckoutStepIndicator(currentStep: _step),
            Expanded(
              child: CheckoutLayout.scrollBody(
                context,
                controller: _scrollController,
                children: [
                  OrderSummaryCard(
                    items: cart.items,
                    subtotalLak: subtotal,
                    shippingFeeLak: shippingFee,
                    totalLak: total,
                    quote: quote,
                    quoteLoading: _quoteLoading,
                    showLineItems: _step == 3,
                    compact: compact || _step < 3,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _buildCurrentStep(cart, total, compact),
                ],
              ),
            ),
            CheckoutBottomBar(child: _buildBottomNav(compact)),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(bool compact) {
    return CheckoutNavButtons(
      showBack: _step > 1,
      compact: compact,
      onBack: () => _goToStep(_step - 1),
      onContinue: _onBottomContinue,
      continueLabel: _step == 3 ? 'ຢືນຢັນຄຳສັ່ງຊື້' : 'ດຳເນີນການຕໍ່',
      continueLoading: _busy && _step == 3,
    );
  }

  Widget _buildCurrentStep(CartProvider cart, double total, bool compact) {
    return switch (_step) {
      1 => _buildShippingStep(compact),
      2 => _buildPaymentStep(total, compact),
      _ => _buildConfirmStep(cart, compact),
    };
  }

  void _onBottomContinue() {
    if (_step == 1) {
      if (_validateShipping()) _goToStep(2);
    } else if (_step == 2) {
      if (_validateReceipt()) _goToStep(3);
    } else if (_step == 3) {
      _submit();
    }
  }

  Widget _buildShippingStep(bool compact) {
    final gap = CheckoutLayout.fieldGap(context);
    final titleSize = CheckoutLayout.titleFontSize(context);
    final inputPadding = compact
        ? const EdgeInsets.symmetric(horizontal: 14, vertical: 12)
        : null;

    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey('step_shipping'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'ທີ່ຢູ່ຈັດສົ່ງ',
            style: GoogleFonts.notoSansLao(fontSize: titleSize, fontWeight: FontWeight.w800),
          ),
          SizedBox(height: CheckoutLayout.sectionGap(context)),
          CheckoutLabeledField(
            icon: Icons.person_outline,
            label: 'ຊື່ຜູ້ຮັບ',
            child: TextFormField(
              controller: _name,
              decoration: InputDecoration(
                hintText: 'ປ້ອນຊື່ຂອງທ່ານ',
                contentPadding: inputPadding,
                isDense: compact,
              ),
              validator: _required,
            ),
          ),
          SizedBox(height: gap),
          CheckoutLabeledField(
            icon: Icons.phone_outlined,
            label: 'ເບີໂທລະສັບ',
            child: TextFormField(
              controller: _phone,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: '020 XXXX XXXX',
                contentPadding: inputPadding,
                isDense: compact,
              ),
              validator: (v) => (v == null || v.trim().length < 8) ? 'ເບີໂທບໍ່ຖືກຕ້ອງ' : null,
            ),
          ),
          SizedBox(height: gap),
          DeliveryLocationPicker(
            latitude: _deliveryLat,
            longitude: _deliveryLng,
            onChanged: (lat, lng) => setState(() {
              _deliveryLat = lat;
              _deliveryLng = lng;
            }),
          ),
          SizedBox(height: gap),
          CheckoutLabeledField(
            icon: Icons.location_on_outlined,
            label: 'ຈຸດສັງເກດ / ທີ່ຢູ່ລະອຽດ',
            child: TextFormField(
              controller: _address,
              maxLines: CheckoutLayout.addressMaxLines(context),
              decoration: InputDecoration(
                hintText: 'ບ້ານ, ເມືອງ, ຈຸດສັງເກດ',
                contentPadding: inputPadding,
                isDense: compact,
              ),
              validator: _required,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStep(double total, bool compact) {
    final titleSize = CheckoutLayout.titleFontSize(context);
    final qrSize = compact ? 140.0 : 180.0;

    return Column(
      key: const ValueKey('step_payment'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'ເລືອກວິທີຊຳລະເງິນ',
          style: GoogleFonts.notoSansLao(fontSize: titleSize, fontWeight: FontWeight.w800),
        ),
        SizedBox(height: CheckoutLayout.sectionGap(context)),
        PaymentMethodTile(
          selected: _paymentMethod == 'bcel_qr',
          icon: Icons.qr_code_2_rounded,
          iconBg: const Color(0xFF2563EB),
          title: 'BCEL One QR',
          subtitle: 'ສະແກນ QR Code ຈ່າຍຜ່ານ BCEL One',
          onTap: () => setState(() => _paymentMethod = 'bcel_qr'),
        ),
        const SizedBox(height: AppSpacing.md),
        PaymentMethodTile(
          selected: _paymentMethod == 'cod',
          icon: Icons.payments_outlined,
          iconBg: AppColors.secondary,
          title: 'ເກັບເງິນປາຍທາງ (COD)',
          subtitle: 'ຈ່າຍເງິນເມື່ອໄດ້ຮັບສິນຄ້າ',
          onTap: () => setState(() {
            _paymentMethod = 'cod';
            _clearReceipt();
          }),
        ),
        if (_paymentMethod == 'bcel_qr') ...[
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
            child: Column(
              children: [
                Text(
                  'ສະແກນ QR Code ເພື່ອຊຳລະເງິນ',
                  style: GoogleFonts.notoSansLao(fontSize: 13, color: AppColors.textSecondary),
                ),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  width: qrSize,
                  height: qrSize,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.qr_code_2_rounded, size: 64, color: AppColors.textMuted.withValues(alpha: 0.6)),
                      const SizedBox(height: AppSpacing.sm),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        child: Text(
                          'QR Code ຈະປະກົດຫຼັງຢືນຢັນຄຳສັ່ງ',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.notoSansLao(fontSize: 11, color: AppColors.textMuted),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  formatLakWeb(total),
                  style: GoogleFonts.notoSansLao(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primary),
                ),
                const SizedBox(height: AppSpacing.lg),
                _buildReceiptUploadSection(),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildConfirmStep(CartProvider cart, bool compact) {
    return Column(
      key: const ValueKey('step_confirm'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'ຢືນຢັນຄຳສັ່ງຊື້',
          style: GoogleFonts.notoSansLao(
            fontSize: CheckoutLayout.titleFontSize(context),
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: CheckoutLayout.sectionGap(context)),
        CheckoutReviewCard(
          title: 'ທີ່ຢູ່ຈັດສົ່ງ',
          onEdit: () => _goToStep(1),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${_name.text.trim()} | ${_phone.text.trim()}',
                style: GoogleFonts.notoSansLao(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                '${_address.text.trim()}, ${VientianeDelivery.provinceName}',
                style: GoogleFonts.notoSansLao(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
        CheckoutReviewCard(
          title: 'ວິທີຊຳລະເງິນ',
          onEdit: () => _goToStep(2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _paymentLabel,
                style: GoogleFonts.notoSansLao(fontSize: 13, color: AppColors.textSecondary),
              ),
              if (_paymentMethod == 'bcel_qr' && _receiptPreviewBytes != null) ...[
                const SizedBox(height: AppSpacing.md),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  child: Image.memory(
                    _receiptPreviewBytes!,
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                ),
              ],
            ],
          ),
        ),
        if (_paymentMethod == 'bcel_qr') ...[
          const SizedBox(height: AppSpacing.lg),
          _buildReceiptUploadSection(compact: true),
        ],
        Text('ສິນຄ້າທີ່ສັ່ງ', style: GoogleFonts.notoSansLao(fontSize: 15, fontWeight: FontWeight.w700)),
        const SizedBox(height: AppSpacing.md),
        ...cart.items.map(
          (item) => Container(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 64,
                  height: 64,
                  child: ProductImage(
                    imageUrl: item.product.imageUrl,
                    productName: item.product.name,
                    aspectRatio: 1,
                    borderRadius: AppSpacing.radiusSm,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name,
                        style: GoogleFonts.notoSansLao(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        'x${item.quantity}',
                        style: GoogleFonts.notoSansLao(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Text(
                  formatLakWeb(item.lineTotalLak),
                  style: GoogleFonts.notoSansLao(fontSize: 14, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildReceiptUploadSection({bool compact = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'ອັບໂຫຼດຫຼັກຖານການຊຳລະເງິນ *',
          style: GoogleFonts.notoSansLao(
            fontSize: compact ? 14 : 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'ອັບໂຫຼດ screenshot ຫຼັງຊຳລະຜ່ານ BCEL One',
          style: GoogleFonts.notoSansLao(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.md),
        InkWell(
          onTap: _busy ? null : _pickReceipt,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Container(
            padding: EdgeInsets.all(compact ? AppSpacing.md : AppSpacing.lg),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              border: Border.all(color: AppColors.border, width: 2),
              color: AppColors.surfaceMuted,
            ),
            child: Column(
              children: [
                if (_receiptPreviewBytes != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                    child: Image.memory(
                      _receiptPreviewBytes!,
                      height: compact ? 100 : 160,
                      fit: BoxFit.contain,
                    ),
                  )
                else ...[
                  Icon(Icons.upload_file_outlined, size: 40, color: AppColors.textMuted.withValues(alpha: 0.7)),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'ກົດເພື່ອເລືອກຮູບ',
                    style: GoogleFonts.notoSansLao(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ],
                if (_receiptFile != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    _receiptFile!.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.notoSansLao(fontSize: 11, color: AppColors.textMuted),
                  ),
                  TextButton(
                    onPressed: _busy ? null : _clearReceipt,
                    child: const Text('ລຶບຮູບ'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  String? _required(String? v) => (v == null || v.trim().isEmpty) ? 'ກະລຸນາໃສ່ຂໍ້ມູນ' : null;
}
