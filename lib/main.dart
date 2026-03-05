import 'package:flutter/material.dart';

import 'app/theme_mode_provider.dart';
import 'app/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/cache/products_cache.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ProductsCache.init();
  runApp(const ProductCatalogApp());
}

class ProductCatalogApp extends StatefulWidget {
  const ProductCatalogApp({super.key});

  @override
  State<ProductCatalogApp> createState() => _ProductCatalogAppState();
}

class _ProductCatalogAppState extends State<ProductCatalogApp> {
  final ThemeModeNotifier _themeNotifier = ThemeModeNotifier();

  @override
  void dispose() {
    _themeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeModeScope(
      notifier: _themeNotifier,
      child: ListenableBuilder(
        listenable: _themeNotifier,
        builder: (context, _) {
          return MaterialApp.router(
            title: 'Product Catalog',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: _themeNotifier.mode,
            routerConfig: AppRouter.createRouter(),
          );
        },
      ),
    );
  }
}
