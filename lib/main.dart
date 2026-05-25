import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/datasources/remote/api_service.dart';
import 'data/repositories/banner_repository_impl.dart';
import 'data/repositories/catalog_repository_impl.dart';
import 'data/repositories/orders_repository_impl.dart';
import 'presentation/providers/banners_provider.dart';
import 'presentation/providers/cart_provider.dart';
import 'presentation/providers/catalog_provider.dart';
import 'presentation/providers/orders_provider.dart';
import 'presentation/screens/shell/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final api = ApiService();
  final catalogRepo = CatalogRepositoryImpl(api);
  final bannerRepo = BannerRepositoryImpl(api);
  final ordersRepo = OrdersRepositoryImpl(api);

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>.value(value: api),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(
          create: (_) => CatalogProvider(catalogRepo)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => BannersProvider(bannerRepo)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => OrdersProvider(ordersRepo),
        ),
      ],
      child: const LaoRiceApp(),
    ),
  );
}

class LaoRiceApp extends StatelessWidget {
  const LaoRiceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ຮ້ານເຂົ້າສານ ວຽງຈັນ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const MainShell(),
    );
  }
}
