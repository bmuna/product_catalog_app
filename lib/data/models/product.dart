import 'package:equatable/equatable.dart';

class Product extends Equatable {
  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    this.discountPercentage,
    this.rating,
    this.stock,
    this.brand,
    this.category,
    this.thumbnail,
    this.images = const [],
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final imagesJson = json['images'] as List<dynamic>?;
    return Product(
      id: json['id'] as int,
      title: json['title'] as String,
      description: (json['description'] as String?) ?? '',
      price: (json['price'] as num).toDouble(),
      discountPercentage: (json['discountPercentage'] as num?)?.toDouble(),
      rating: (json['rating'] as num?)?.toDouble(),
      stock: json['stock'] as int?,
      brand: json['brand'] as String?,
      category: json['category'] as String?,
      thumbnail: json['thumbnail'] as String?,
      images: imagesJson != null
          ? imagesJson.map((e) => e as String).toList()
          : const [],
    );
  }

  final int id;
  final String title;
  final String description;
  final double price;
  final double? discountPercentage;
  final double? rating;
  final int? stock;
  final String? brand;
  final String? category;
  final String? thumbnail;
  final List<String> images;

  String get priceDisplay => '\$${price.toStringAsFixed(2)}';

  String? get discountedPriceDisplay {
    if (discountPercentage == null) return null;
    final discounted = price * (1 - discountPercentage! / 100);
    return '\$${discounted.toStringAsFixed(2)}';
  }

  String get brandDisplay => brand ?? 'Unknown brand';

  String get categoryDisplay => category ?? 'Uncategorized';

  @override
  List<Object?> get props => [id, title, description, price, discountPercentage, rating, stock, brand, category, thumbnail, images];
}
