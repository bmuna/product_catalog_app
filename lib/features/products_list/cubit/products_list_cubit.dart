import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/constants/app_constants.dart';
import '../../../data/repositories/products_repository.dart';
import 'products_list_state.dart';

class ProductsListCubit extends Cubit<ProductsListState> {
  ProductsListCubit({ProductsRepository? repository})
      : _repository = repository ?? ProductsRepository(),
        super(const ProductsListState());

  final ProductsRepository _repository;

  Future<void> loadInitial({bool force = false, bool bypassCache = false}) async {
    if (!force && state.status == ProductsListStatus.loading) return;
    emit(state.copyWith(products: force ? [] : state.products, status: ProductsListStatus.loading, errorMessage: null));
    try {
      final categories = await _repository.getCategories();
      final response = await _repository.getProducts(
        limit: AppConstants.productsPerPage,
        skip: 0,
        searchQuery: state.searchQuery.isEmpty ? null : state.searchQuery,
        category: state.selectedCategory,
        bypassCache: bypassCache,
      );
      final isEmpty = response.products.isEmpty;
      emit(state.copyWith(
        status: isEmpty ? ProductsListStatus.empty : ProductsListStatus.loaded,
        products: response.products,
        categories: categories,
        hasMore: response.hasMore,
        errorMessage: null,
        isFromCache: response.isFromCache,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductsListStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> loadMore() async {
    if (!state.hasMore ||
        state.status == ProductsListStatus.loading ||
        state.status == ProductsListStatus.loadingMore) {
      return;
    }
    if (state.products.isEmpty) {
      return;
    }
    emit(state.copyWith(status: ProductsListStatus.loadingMore));
    try {
      final skip = state.products.length;
      final response = await _repository.getProducts(
        limit: AppConstants.productsPerPage,
        skip: skip,
        searchQuery: state.searchQuery.isEmpty ? null : state.searchQuery,
        category: state.selectedCategory,
      );
      final newProducts = [...state.products, ...response.products];
      emit(state.copyWith(
        status: ProductsListStatus.loaded,
        products: newProducts,
        hasMore: response.hasMore,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: ProductsListStatus.loaded,
        errorMessage: e.toString(),
      ));
    }
  }

  void setSearchQuery(String query) {
    if (state.searchQuery == query) return;
    emit(state.copyWith(searchQuery: query));
  }

  void setCategory(String? category) {
    if (state.selectedCategory == category) return;
    emit(state.copyWith(selectedCategory: category));
  }

  Future<void> applyFiltersAndReload() async {
    await loadInitial(force: true);
  }

  Future<void> refresh() async {
    await _repository.invalidateCache();
    await loadInitial(force: true, bypassCache: true);
  }
}
