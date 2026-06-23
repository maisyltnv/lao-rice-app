import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/datasources/remote/api_service.dart';
import 'data/repositories/banner_repository_impl.dart';
import 'data/repositories/catalog_repository_impl.dart';
import 'data/repositories/orders_repository_impl.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/banners_provider.dart';
import 'presentation/providers/cart_provider.dart';
import 'presentation/providers/catalog_provider.dart';
import 'presentation/providers/orders_provider.dart';
import 'presentation/screens/shell/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('lo_LA');

  final api = ApiService();
  final auth = AuthProvider(api);
  await auth.bootstrap();

  final catalogRepo = CatalogRepositoryImpl(api);
  final bannerRepo = BannerRepositoryImpl(api);
  final ordersRepo = OrdersRepositoryImpl(api);

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>.value(value: api),
        ChangeNotifierProvider<AuthProvider>.value(value: auth),
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
      title: 'ເຂົ້າສານ ວຽງຈັນ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: MainShell(key: MainShell.shellKey),
    );
  }
}
