import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../app/theme_mode_provider.dart' show ThemeModeScope;
import '../../../core/constants/app_constants.dart';
import '../../../design_system/design_system.dart';
import '../../../data/models/product.dart';
import '../cubit/products_list_cubit.dart';
import '../cubit/products_list_state.dart';

class ProductsListScreen extends StatefulWidget {
  const ProductsListScreen({super.key, this.isMasterDetail = false});

  final bool isMasterDetail;

  @override
  State<ProductsListScreen> createState() => _ProductsListScreenState();
}

class _ProductsListScreenState extends State<ProductsListScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    context.read<ProductsListCubit>().loadInitial();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final cubit = context.read<ProductsListCubit>();
    final state = cubit.state;
    if (!state.hasMore || state.status != ProductsListStatus.loaded) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 200) {
      cubit.loadMore();
    }
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(
      const Duration(milliseconds: AppConstants.searchDebounceMs),
      () {
        context.read<ProductsListCubit>()
          ..setSearchQuery(value)
          ..applyFiltersAndReload();
      },
    );
  }

  void _onProductTap(Product product) {
    final path = '/products/${product.id}';
    if (widget.isMasterDetail) {
      context.go(path);
    } else {
      context.push(path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: Icon(Theme.of(context).brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle theme',
            onPressed: () => ThemeModeScope.of(context).toggle(),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: DesignSearchBar(
              controller: _searchController,
              onChanged: _onSearchChanged,
            ),
          ),
          BlocBuilder<ProductsListCubit, ProductsListState>(
            buildWhen: (a, b) => a.categories != b.categories || a.selectedCategory != b.selectedCategory,
            builder: (context, state) {
              if (state.categories.isEmpty) return const SizedBox.shrink();
              return SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: state.categories.length + 1,
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return CategoryChip(
                        label: 'All',
                        selected: state.selectedCategory == null,
                        onTap: () {
                          context.read<ProductsListCubit>()
                            ..setCategory(null)
                            ..applyFiltersAndReload();
                        },
                      );
                    }
                    final category = state.categories[index - 1];
                    return CategoryChip(
                      label: category.name,
                      selected: state.selectedCategory == category.slug,
                      onTap: () {
                        context.read<ProductsListCubit>()
                          ..setCategory(category.slug)
                          ..applyFiltersAndReload();
                      },
                    );
                  },
                ),
              );
            },
          ),
          BlocBuilder<ProductsListCubit, ProductsListState>(
            buildWhen: (a, b) => a.isFromCache != b.isFromCache,
            builder: (context, state) {
              if (!state.isFromCache) return const SizedBox.shrink();
              final theme = Theme.of(context);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: theme.colorScheme.surfaceContainerHighest,
                child: Row(
                  children: [
                    Icon(
                      Icons.offline_bolt_rounded,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Cached',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: BlocBuilder<ProductsListCubit, ProductsListState>(
              builder: (context, state) {
                if (state.status == ProductsListStatus.loading) {
                  return const _SkeletonGrid();
                }
                if (state.status == ProductsListStatus.error) {
                  return ErrorState(
                    message: state.errorMessage ?? 'Failed to load products',
                    onRetry: () => context.read<ProductsListCubit>().loadInitial(),
                  );
                }
                if (state.status == ProductsListStatus.empty ||
                    state.products.isEmpty) {
                  return const EmptyState(
                    message: 'No products found',
                    subtitle: 'Try a different search or category',
                  );
                }
                return RefreshIndicator(
                  onRefresh: () => context.read<ProductsListCubit>().refresh(),
                  child: GridView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 0.72,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemCount: state.products.length + (state.hasMore && state.status == ProductsListStatus.loadingMore ? 1 : 0),
                    cacheExtent: 400,
                    addRepaintBoundaries: true,
                    itemBuilder: (context, index) {
                      if (index >= state.products.length) {
                        return const LoadingFooter();
                      }
                      final product = state.products[index];
                      return ProductCard(
                        key: ValueKey(product.id),
                        data: ProductCardData(
                          id: product.id,
                          title: product.title,
                          priceText: product.priceDisplay,
                          thumbnailUrl: product.thumbnail,
                          rating: product.rating,
                          brand: product.brand,
                          category: product.category,
                        ),
                        onTap: () => _onProductTap(product),
                      )
                          .animate()
                          .fadeIn(
                            delay: Duration(milliseconds: index * 40),
                            duration: const Duration(milliseconds: 280),
                          )
                          .slideY(
                            begin: 0.05,
                            end: 0,
                            duration: const Duration(milliseconds: 280),
                            delay: Duration(milliseconds: index * 40),
                          );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SkeletonGrid extends StatelessWidget {
  const _SkeletonGrid();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: 10,
      addRepaintBoundaries: true,
      itemBuilder: (context, index) => const SkeletonCard(),
    );
  }
}
