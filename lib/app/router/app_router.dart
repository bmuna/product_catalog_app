import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../features/product_detail/cubit/product_detail_cubit.dart';
import '../../features/product_detail/screens/product_detail_screen.dart';
import '../../features/products_list/cubit/products_list_cubit.dart';
import '../../features/products_list/screens/products_list_screen.dart';
import '../../features/products_list/screens/responsive_products_shell.dart';

class AppRouter {
  AppRouter._();

  static const String productsPath = '/products';
  static const String productDetailPath = 'products/:id';

  static GoRouter createRouter() {
    return GoRouter(
      initialLocation: productsPath,
      routes: [
        GoRoute(
          path: '/',
          redirect: (context, state) => productsPath,
        ),
        GoRoute(
          path: productsPath,
          builder: (context, state) {
            final isTablet = _isTablet(context);
            final id = state.pathParameters['id'];
            if (isTablet) {
              return ResponsiveProductsShell(
                productId: id != null ? int.tryParse(id) : null,
              );
            }
            return BlocProvider(
              create: (_) => ProductsListCubit(),
              child: const ProductsListScreen(),
            );
          },
        ),
        GoRoute(
          path: '/products/:id',
          builder: (context, state) {
            final idStr = state.pathParameters['id'];
            final id = idStr != null ? int.tryParse(idStr) : null;
            final isTablet = _isTablet(context);
            if (isTablet) {
              return ResponsiveProductsShell(productId: id);
            }
            if (id == null) {
              return BlocProvider(
                create: (_) => ProductsListCubit(),
                child: const ProductsListScreen(),
              );
            }
            return BlocProvider(
              create: (_) => ProductDetailCubit()..loadProduct(id),
              child: ProductDetailScreen(productId: id),
            );
          },
        ),
      ],
    );
  }

  static bool _isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= AppConstants.tabletBreakpoint;
  }
}
