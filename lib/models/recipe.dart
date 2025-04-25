import 'package:equatable/equatable.dart';

/// Model class representing a recipe from TheMealDB API
class Recipe extends Equatable {
  final String id;
  final String name;
  final String category;
  final String area;
  final String instructions;
  final String thumbnailUrl;
  final String? youtubeUrl;
  final Map<String, dynamic> originalData;
  final List<String> ingredients;
  final List<String> measurements;
  final Map<String, String> ingredientsWithMeasurements;
  final List<String> tags;

  const Recipe({
    required this.id,
    required this.name,
    required this.category,
    required this.area,
    required this.instructions,
    required this.thumbnailUrl,
    this.youtubeUrl,
    required this.originalData,
    required this.ingredients,
    required this.measurements,
    required this.ingredientsWithMeasurements,
    required this.tags,
  });

  /// Creates a Recipe from TheMealDB API JSON response
  factory Recipe.fromJson(Map<String, dynamic> json) {
    // Extract ingredients and measurements from the API response
    final ingredients = <String>[];
    final measurements = <String>[];
    final ingredientsWithMeasurements = <String, String>{};

    // TheMealDB API returns ingredients as strIngredient1, strIngredient2, etc.
    // and measurements as strMeasure1, strMeasure2, etc.
    for (int i = 1; i <= 20; i++) {
      final ingredient = json['strIngredient$i'];
      final measurement = json['strMeasure$i'];

      if (ingredient != null && ingredient.toString().trim().isNotEmpty) {
        ingredients.add(ingredient.toString().trim());
        measurements.add(measurement?.toString().trim() ?? '');
        ingredientsWithMeasurements[ingredient.toString().trim()] = 
            measurement?.toString().trim() ?? '';
      }
    }

    // Parse tags
    final tagsString = json['strTags'];
    final tags = tagsString != null && tagsString.toString().isNotEmpty
        ? tagsString.toString().split(',').map((tag) => tag.trim()).toList()
        : <String>[];

    return Recipe(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? '',
      category: json['strCategory'] ?? '',
      area: json['strArea'] ?? '',
      instructions: json['strInstructions'] ?? '',
      thumbnailUrl: json['strMealThumb'] ?? '',
      youtubeUrl: json['strYoutube'],
      originalData: json,
      ingredients: ingredients,
      measurements: measurements,
      ingredientsWithMeasurements: ingredientsWithMeasurements,
      tags: tags,
    );
  }

  /// Creates a simplified Recipe from minimal JSON data
  /// Used for list views and search results
  factory Recipe.fromMinimalJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? '',
      category: json['strCategory'] ?? '',
      area: json['strArea'] ?? '',
      instructions: '',
      thumbnailUrl: json['strMealThumb'] ?? '',
      ingredients: const [],
      measurements: const [],
      ingredientsWithMeasurements: const {},
      tags: const [],
      originalData: json,
    );
  }

  /// Convert Recipe to JSON
  Map<String, dynamic> toJson() {
    return {
      'idMeal': id,
      'strMeal': name,
      'strCategory': category,
      'strArea': area,
      'strInstructions': instructions,
      'strMealThumb': thumbnailUrl,
      'strYoutube': youtubeUrl,
      'ingredients': ingredients,
      'measurements': measurements,
      'tags': tags.join(','),
    };
  }

  /// Get ingredient at the specified index (1-20)
  String? getIngredient(int index) {
    if (index < 1 || index > 20) return null;
    final ingredient = originalData['strIngredient$index'];
    if (ingredient == null || ingredient.toString().trim().isEmpty) {
      return null;
    }
    return ingredient.toString();
  }

  /// Get measurement at the specified index (1-20)
  String? getMeasurement(int index) {
    if (index < 1 || index > 20) return null;
    final measurement = originalData['strMeasure$index'];
    if (measurement == null || measurement.toString().trim().isEmpty) {
      return null;
    }
    return measurement.toString();
  }

  /// Creates a copy of this Recipe with the given fields replaced with the new values
  Recipe copyWith({
    String? id,
    String? name,
    String? category,
    String? area,
    String? instructions,
    String? thumbnailUrl,
    String? youtubeUrl,
    List<String>? ingredients,
    List<String>? measurements,
    Map<String, String>? ingredientsWithMeasurements,
    List<String>? tags,
    Map<String, dynamic>? originalData,
  }) {
    return Recipe(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      area: area ?? this.area,
      instructions: instructions ?? this.instructions,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      youtubeUrl: youtubeUrl ?? this.youtubeUrl,
      ingredients: ingredients ?? this.ingredients,
      measurements: measurements ?? this.measurements,
      ingredientsWithMeasurements: ingredientsWithMeasurements ?? this.ingredientsWithMeasurements,
      tags: tags ?? this.tags,
      originalData: originalData ?? this.originalData,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        category,
        area,
        instructions,
        thumbnailUrl,
        youtubeUrl,
        ingredients,
        measurements,
        ingredientsWithMeasurements,
        tags,
        originalData,
      ];
}
