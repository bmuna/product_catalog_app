import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/design_system.dart';
import 'products_list_screen.dart';
import '../cubit/products_list_cubit.dart';
import '../../product_detail/screens/product_detail_screen.dart';
import '../../product_detail/cubit/product_detail_cubit.dart';
import '../../../core/constants/app_constants.dart';

class ResponsiveProductsShell extends StatelessWidget {
  const ResponsiveProductsShell({super.key, this.productId});

  final int? productId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ProductsListCubit()),
        BlocProvider(create: (_) => ProductDetailCubit()),
      ],
      child: _ResponsiveProductsShellContent(productId: productId),
    );
  }
}

class _ResponsiveProductsShellContent extends StatefulWidget {
  const _ResponsiveProductsShellContent({this.productId});

  final int? productId;

  @override
  State<_ResponsiveProductsShellContent> createState() =>
      _ResponsiveProductsShellContentState();
}

class _ResponsiveProductsShellContentState
    extends State<_ResponsiveProductsShellContent> {
  int? _lastLoadedId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final id = widget.productId ?? _getIdFromRoute(context);
    if (id != null && id != _lastLoadedId) {
      _lastLoadedId = id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) context.read<ProductDetailCubit>().loadProduct(id);
      });
    }
  }

  int? _getIdFromRoute(BuildContext context) {
    final state = GoRouterState.of(context);
    final segments = state.uri.pathSegments;
    if (segments.length < 2) return null;
    return int.tryParse(segments[1]);
  }

  @override
  Widget build(BuildContext context) {
    final id = _getIdFromRoute(context) ?? widget.productId;
    return Row(
      children: [
        SizedBox(
          width: AppConstants.masterPanelWidth,
          child: ProductsListScreen(isMasterDetail: true),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: id == null
              ? const _EmptyDetailPanel()
              : ProductDetailScreen(productId: id, isEmbedded: true),
        ),
      ],
    );
  }
}

class _EmptyDetailPanel extends StatelessWidget {
  const _EmptyDetailPanel();

  @override
  Widget build(BuildContext context) {
    return const EmptyState(
      message: 'Select a product',
      subtitle: 'Choose an item from the list to view details',
      icon: Icons.touch_app_outlined,
    );
  }
}
