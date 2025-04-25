import 'package:equatable/equatable.dart';

/// Model class representing a recipe category from TheMealDB API
class Category extends Equatable {
  final String id;
  final String name;
  final String thumbnailUrl;
  final String description;

  const Category({
    required this.id,
    required this.name,
    required this.thumbnailUrl,
    required this.description,
  });

  /// Creates a Category from TheMealDB API JSON response
  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['idCategory'] ?? '',
      name: json['strCategory'] ?? '',
      thumbnailUrl: json['strCategoryThumb'] ?? '',
      description: json['strCategoryDescription'] ?? '',
    );
  }

  /// Convert Category to JSON
  Map<String, dynamic> toJson() {
    return {
      'idCategory': id,
      'strCategory': name,
      'strCategoryThumb': thumbnailUrl,
      'strCategoryDescription': description,
    };
  }

  @override
  List<Object?> get props => [id, name, thumbnailUrl, description];
}
