import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/cart_provider.dart';
import '../../presentation/providers/orders_provider.dart';
import '../../presentation/screens/cart/checkout_screen.dart';

/// ຫຼັງເຂົ້າລະບົບ OTP: ກະຕ່າມີສິນຄ້າ → checkout, ບໍ່ມີ → ກັບໜ້າຫຼັກ (ເຊັນກັນກັບ web).
void navigateAfterPhoneLogin(BuildContext context, {VoidCallback? onSuccess}) {
  if (onSuccess != null) {
    onSuccess();
    return;
  }

  final auth = context.read<AuthProvider>();
  final orders = context.read<OrdersProvider>();
  final accountPhone = auth.phone;
  if (accountPhone != null && accountPhone.isNotEmpty) {
    orders.savePhone(accountPhone);
  }

  final cart = context.read<CartProvider>();
  final navigator = Navigator.of(context);

  if (cart.isEmpty) {
    navigator.popUntil((route) => route.isFirst);
    return;
  }

  navigator.pushReplacement(
    MaterialPageRoute<void>(builder: (_) => const CheckoutScreen()),
  );
}
