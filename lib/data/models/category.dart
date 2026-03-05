import 'package:equatable/equatable.dart';

class Category extends Equatable {
  const Category({required this.slug, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      slug: json['slug'] as String,
      name: json['name'] as String,
    );
  }

  final String slug;
  final String name;

  @override
  List<Object?> get props => [slug, name];
}
