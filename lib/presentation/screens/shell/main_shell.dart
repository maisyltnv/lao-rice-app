import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../providers/cart_provider.dart';
import '../cart/cart_screen.dart';
import '../info/delivery_info_screen.dart';
import '../home/home_screen.dart';
import '../orders/order_history_screen.dart';
import '../profile/profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  static const _titles = ['', 'ກະເປົາຂອງຂ້ອຍ', 'ຄຳສັ່ງຊື້', 'ຈັດສົ່ງ', 'ຕັ້ງຄ່າ'];

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final isHome = _index == 0;

    final body = switch (_index) {
      0 => const HomeScreen(),
      1 => const CartScreen(),
      2 => const OrderHistoryScreen(),
      3 => const DeliveryInfoScreen(),
      _ => const ProfileScreen(),
    };

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: isHome
          ? null
          : AppBar(
              title: Text(_titles[_index]),
              backgroundColor: AppColors.background,
            ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        child: KeyedSubtree(key: ValueKey(_index), child: body),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            backgroundColor: Colors.transparent,
            elevation: 0,
            height: 64,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.storefront_outlined),
                selectedIcon: Icon(Icons.storefront_rounded),
                label: 'ຮ້ານ',
              ),
              NavigationDestination(
                icon: _NavIcon(icon: Icons.shopping_bag_outlined, badge: cart.itemCount),
                selectedIcon: _NavIcon(icon: Icons.shopping_bag_rounded, badge: cart.itemCount, selected: true),
                label: 'ກະເປົາ',
              ),
              const NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long_rounded),
                label: 'ຄຳສັ່ງຊື້',
              ),
              const NavigationDestination(
                icon: Icon(Icons.local_shipping_outlined),
                selectedIcon: Icon(Icons.local_shipping_rounded),
                label: 'ຈັດສົ່ງ',
              ),
              const NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings_rounded),
                label: 'ຕັ້ງຄ່າ',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavIcon extends StatelessWidget {
  const _NavIcon({required this.icon, required this.badge, this.selected = false});

  final IconData icon;
  final int badge;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final child = Icon(icon, color: selected ? AppColors.primary : AppColors.textMuted);
    if (badge <= 0) return child;
    return Badge(
      label: Text('$badge', style: const TextStyle(color: AppColors.onSecondary, fontSize: 11)),
      backgroundColor: AppColors.secondary,
      child: child,
    );
  }
}
