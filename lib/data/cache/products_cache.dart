import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../models/category.dart';
import '../models/product.dart';

const String _boxName = 'products_cache';
const String _keyProducts = 'products';
const String _keyCategories = 'categories';
const String _keyCachedAt = 'cached_at';

const Duration cacheValidity = Duration(minutes: 5);

class ProductsCache {
  static Box<String>? _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    if (!Hive.isBoxOpen(_boxName)) {
      _box = await Hive.openBox<String>(_boxName);
    } else {
      _box = Hive.box<String>(_boxName);
    }
  }

  static Box<String> get box {
    final b = _box;
    if (b == null) throw StateError('ProductsCache not initialized. Call init() first.');
    return b;
  }

  static bool get _isStale {
    final at = box.get(_keyCachedAt);
    if (at == null) return true;
    final ms = int.tryParse(at);
    if (ms == null) return true;
    return DateTime.now().millisecondsSinceEpoch - ms > cacheValidity.inMilliseconds;
  }

  static CachedProductsResult? getCachedProducts() {
    final productsJson = box.get(_keyProducts);
    final categoriesJson = box.get(_keyCategories);
    if (productsJson == null || categoriesJson == null || _isStale) return null;
    try {
      final productsMap = jsonDecode(productsJson) as Map<String, dynamic>;
      final productsList = productsMap['products'] as List<dynamic>;
      final total = productsMap['total'] as int;
      final products = productsList
          .map((e) => Product.fromJson(e as Map<String, dynamic>))
          .toList();
      final categoriesList = jsonDecode(categoriesJson) as List<dynamic>;
      final categories = categoriesList
          .whereType<Map<String, dynamic>>()
          .map((e) => Category.fromJson(e))
          .toList();
      return CachedProductsResult(
        products: products,
        total: total,
        categories: categories,
      );
    } catch (_) {
      return null;
    }
  }

  static Future<void> setCachedProducts({
    required List<Product> products,
    required int total,
    required List<Category> categories,
  }) async {
    final productsMap = {
      'products': products.map((p) => _productToJson(p)).toList(),
      'total': total,
    };
    final categoriesMap = categories.map((c) => {'slug': c.slug, 'name': c.name}).toList();
    await box.put(_keyProducts, jsonEncode(productsMap));
    await box.put(_keyCategories, jsonEncode(categoriesMap));
    await box.put(_keyCachedAt, DateTime.now().millisecondsSinceEpoch.toString());
  }

  static Map<String, dynamic> _productToJson(Product p) {
    return {
      'id': p.id,
      'title': p.title,
      'description': p.description,
      'price': p.price,
      'discountPercentage': p.discountPercentage,
      'rating': p.rating,
      'stock': p.stock,
      'brand': p.brand,
      'category': p.category,
      'thumbnail': p.thumbnail,
      'images': p.images,
    };
  }

  static Future<void> invalidate() async {
    await box.delete(_keyProducts);
    await box.delete(_keyCategories);
    await box.delete(_keyCachedAt);
  }
}

class CachedProductsResult {
  const CachedProductsResult({
    required this.products,
    required this.total,
    required this.categories,
  });

  final List<Product> products;
  final int total;
  final List<Category> categories;
}
