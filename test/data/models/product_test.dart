import 'package:flutter_test/flutter_test.dart';
import 'package:product_catalog_app/data/models/product.dart';

void main() {
  group('Product.fromJson', () {
    test('parses valid product with all fields', () {
      final json = {
        'id': 1,
        'title': 'Test Product',
        'description': 'A test',
        'price': 99.99,
        'discountPercentage': 10.0,
        'rating': 4.5,
        'stock': 100,
        'brand': 'TestBrand',
        'category': 'electronics',
        'thumbnail': 'https://example.com/thumb.jpg',
        'images': ['https://example.com/1.jpg', 'https://example.com/2.jpg'],
      };
      final product = Product.fromJson(json);
      expect(product.id, 1);
      expect(product.title, 'Test Product');
      expect(product.description, 'A test');
      expect(product.price, 99.99);
      expect(product.discountPercentage, 10.0);
      expect(product.rating, 4.5);
      expect(product.stock, 100);
      expect(product.brand, 'TestBrand');
      expect(product.category, 'electronics');
      expect(product.thumbnail, 'https://example.com/thumb.jpg');
      expect(product.images, hasLength(2));
      expect(product.priceDisplay, '\$99.99');
      expect(product.brandDisplay, 'TestBrand');
      expect(product.categoryDisplay, 'electronics');
    });

    test('parses product with only required fields', () {
      final json = {
        'id': 2,
        'title': 'Minimal',
        'description': '',
        'price': 0,
      };
      final product = Product.fromJson(json);
      expect(product.id, 2);
      expect(product.title, 'Minimal');
      expect(product.description, '');
      expect(product.price, 0);
      expect(product.discountPercentage, isNull);
      expect(product.rating, isNull);
      expect(product.stock, isNull);
      expect(product.brand, isNull);
      expect(product.category, isNull);
      expect(product.thumbnail, isNull);
      expect(product.images, isEmpty);
      expect(product.priceDisplay, '\$0.00');
      expect(product.brandDisplay, 'Unknown brand');
      expect(product.categoryDisplay, 'Uncategorized');
    });

    test('computes discounted price when discount set', () {
      final json = {
        'id': 4,
        'title': 'Sale',
        'description': '',
        'price': 100,
        'discountPercentage': 20,
      };
      final product = Product.fromJson(json);
      expect(product.discountedPriceDisplay, isNotNull);
      expect(product.discountedPriceDisplay, '\$80.00');
    });
  });
}
