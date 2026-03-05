import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/constants/app_constants.dart';
import '../models/category.dart';
import '../models/product.dart';

class ProductsApi {
  ProductsApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  static const String _base = AppConstants.apiBaseUrl;

  Future<http.Response> _get(Uri uri) async {
    final response = await _client.get(uri);
    return response;
  }

  Future<ProductsResponse> getProducts({int limit = AppConstants.productsPerPage, int skip = 0}) async {
    final uri = Uri.parse('$_base/products?limit=$limit&skip=$skip');
    final response = await _get(uri);
    if (response.statusCode != 200) {
      throw ProductsApiException('Failed to load products: ${response.statusCode}');
    }
    final map = jsonDecode(response.body) as Map<String, dynamic>;
    return ProductsResponse.fromJson(map);
  }

  Future<ProductsResponse> searchProducts({required String query, int limit = AppConstants.productsPerPage, int skip = 0}) async {
    final encoded = Uri.encodeComponent(query);
    final uri = Uri.parse('$_base/products/search?q=$encoded&limit=$limit&skip=$skip');
    final response = await _get(uri);
    if (response.statusCode != 200) {
      throw ProductsApiException('Search failed: ${response.statusCode}');
    }
    final map = jsonDecode(response.body) as Map<String, dynamic>;
    return ProductsResponse.fromJson(map);
  }

  Future<List<Category>> getCategories() async {
    final uri = Uri.parse('$_base/products/categories');
    final response = await _get(uri);
    if (response.statusCode != 200) {
      throw ProductsApiException('Failed to load categories: ${response.statusCode}');
    }
    final list = jsonDecode(response.body) as List<dynamic>;
    return list.whereType<Map<String, dynamic>>().map((e) => Category.fromJson(e)).toList();
  }

  Future<ProductsResponse> getProductsByCategory({
    required String category,
    int limit = AppConstants.productsPerPage,
    int skip = 0,
  }) async {
    final encoded = Uri.encodeComponent(category);
    final uri = Uri.parse('$_base/products/category/$encoded?limit=$limit&skip=$skip');
    final response = await _get(uri);
    if (response.statusCode != 200) {
      throw ProductsApiException('Failed to load category products: ${response.statusCode}');
    }
    final map = jsonDecode(response.body) as Map<String, dynamic>;
    return ProductsResponse.fromJson(map);
  }

  Future<Product?> getProductById(int id) async {
    final uri = Uri.parse('$_base/products/$id');
    final response = await _get(uri);
    if (response.statusCode == 404) return null;
    if (response.statusCode != 200) {
      throw ProductsApiException('Failed to load product: ${response.statusCode}');
    }
    final map = jsonDecode(response.body) as Map<String, dynamic>;
    return Product.fromJson(map);
  }
}

class ProductsApiException implements Exception {
  ProductsApiException(this.message);
  final String message;
  @override
  String toString() => message;
}

class ProductsResponse {
  const ProductsResponse({required this.products, required this.total});

  factory ProductsResponse.fromJson(Map<String, dynamic> json) {
    final list = json['products'] as List<dynamic>;
    return ProductsResponse(
      products: list.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList(),
      total: json['total'] as int,
    );
  }

  final List<Product> products;
  final int total;
}
 