import 'package:equatable/equatable.dart';

import '../../../data/models/category.dart';
import '../../../data/models/product.dart';

enum ProductsListStatus { initial, loading, loaded, loadingMore, error, empty }

const _undefined = Object();

class ProductsListState extends Equatable {
  const ProductsListState({
    this.status = ProductsListStatus.initial,
    this.products = const [],
    this.categories = const [],
    this.selectedCategory,
    this.searchQuery = '',
    this.hasMore = true,
    this.errorMessage,
    this.isFromCache = false,
  });

  final ProductsListStatus status;
  final List<Product> products;
  final List<Category> categories;
  final String? selectedCategory;
  final String searchQuery;
  final bool hasMore;
  final String? errorMessage;
  final bool isFromCache;

  ProductsListState copyWith({
    ProductsListStatus? status,
    List<Product>? products,
    List<Category>? categories,
    Object? selectedCategory = _undefined,
    String? searchQuery,
    bool? hasMore,
    Object? errorMessage = _undefined,
    bool? isFromCache,
  }) {
    return ProductsListState(
      status: status ?? this.status,
      products: products ?? this.products,
      categories: categories ?? this.categories,
      selectedCategory: identical(selectedCategory, _undefined)
          ? this.selectedCategory
          : selectedCategory as String?,
      searchQuery: searchQuery ?? this.searchQuery,
      hasMore: hasMore ?? this.hasMore,
      errorMessage: identical(errorMessage, _undefined)
          ? this.errorMessage
          : errorMessage as String?,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  @override
  List<Object?> get props => [status, products, categories, selectedCategory, searchQuery, hasMore, errorMessage, isFromCache];
}
