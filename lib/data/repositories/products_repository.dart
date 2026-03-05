import '../../core/constants/app_constants.dart';
import '../api/products_api.dart';
import '../cache/products_cache.dart';
import '../models/category.dart';
import '../models/product.dart';

class ProductsRepository {
  ProductsRepository({ProductsApi? api}) : _api = api ?? ProductsApi();

  final ProductsApi _api;

  Future<ProductsRepositoryResponse> getProducts({
    int limit = AppConstants.productsPerPage,
    int skip = 0,
    String? searchQuery,
    String? category,
    bool bypassCache = false,
  }) async {
    final isDefaultFirstPage = skip == 0 &&
        (searchQuery == null || searchQuery.isEmpty) &&
        (category == null || category.isEmpty);

    if (isDefaultFirstPage && !bypassCache) {
      final cached = ProductsCache.getCachedProducts();
      if (cached != null) {
        return ProductsRepositoryResponse(
          products: cached.products,
          total: cached.total,
          hasMore: cached.products.length < cached.total,
          isFromCache: true,
        );
      }
    }

    if (category != null && category.isNotEmpty) {
      final response = await _api.getProductsByCategory(
        category: category,
        limit: limit,
        skip: skip,
      );
      var products = response.products;
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        products = products
            .where((p) =>
                p.title.toLowerCase().contains(q) ||
                (p.brand?.toLowerCase().contains(q) ?? false))
            .toList();
      }
      return ProductsRepositoryResponse(
        products: products,
        total: response.total,
        hasMore: skip + products.length < response.total,
        isFromCache: false,
      );
    }

    if (searchQuery != null && searchQuery.isNotEmpty) {
      final response = await _api.searchProducts(
        query: searchQuery,
        limit: limit,
        skip: skip,
      );
      return ProductsRepositoryResponse(
        products: response.products,
        total: response.total,
        hasMore: skip + response.products.length < response.total,
        isFromCache: false,
      );
    }

    final response = await _api.getProducts(limit: limit, skip: skip);
    if (isDefaultFirstPage) {
      final categories = await _api.getCategories();
      await ProductsCache.setCachedProducts(
        products: response.products,
        total: response.total,
        categories: categories,
      );
    }
    return ProductsRepositoryResponse(
      products: response.products,
      total: response.total,
      hasMore: skip + response.products.length < response.total,
      isFromCache: false,
    );
  }

  Future<List<Category>> getCategories() async {
    final cached = ProductsCache.getCachedProducts();
    if (cached != null) return cached.categories;
    return _api.getCategories();
  }

  Future<Product?> getProductById(int id) => _api.getProductById(id);

  Future<void> invalidateCache() => ProductsCache.invalidate();
}

class ProductsRepositoryResponse {
  const ProductsRepositoryResponse({
    required this.products,
    required this.total,
    required this.hasMore,
    this.isFromCache = false,
  });

  final List<Product> products;
  final int total;
  final bool hasMore;
  final bool isFromCache;
}
