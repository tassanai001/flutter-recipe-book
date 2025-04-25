import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_book/models/recipe.dart';

void main() {
  group('Recipe Model Tests', () {
    // Test data
    final Map<String, dynamic> testJson = {
      'idMeal': '52772',
      'strMeal': 'Teriyaki Chicken Casserole',
      'strCategory': 'Chicken',
      'strArea': 'Japanese',
      'strInstructions': 'Preheat oven to 350° F. Spray a 9x13-inch baking pan with non-stick spray.',
      'strMealThumb': 'https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg',
      'strYoutube': 'https://www.youtube.com/watch?v=4aZr5hZXP_s',
      'strIngredient1': 'soy sauce',
      'strIngredient2': 'water',
      'strIngredient3': 'brown sugar',
      'strIngredient4': 'ground ginger',
      'strIngredient5': 'minced garlic',
      'strIngredient6': 'cornstarch',
      'strIngredient7': 'chicken breasts',
      'strIngredient8': 'stir-fry vegetables',
      'strIngredient9': 'brown rice',
      'strIngredient10': '',
      'strMeasure1': '3/4 cup',
      'strMeasure2': '1/2 cup',
      'strMeasure3': '1/4 cup',
      'strMeasure4': '1/2 teaspoon',
      'strMeasure5': '1/2 teaspoon',
      'strMeasure6': '4 Tablespoons',
      'strMeasure7': '2',
      'strMeasure8': '1 (12 oz.)',
      'strMeasure9': '3 cups',
      'strMeasure10': '',
      'strTags': 'Meat,Casserole',
    };

    final Map<String, dynamic> minimalJson = {
      'idMeal': '52772',
      'strMeal': 'Teriyaki Chicken Casserole',
      'strCategory': 'Chicken',
      'strArea': 'Japanese',
      'strMealThumb': 'https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg',
    };

    test('fromJson() should correctly parse JSON data', () {
      // Act
      final recipe = Recipe.fromJson(testJson);

      // Assert
      expect(recipe.id, '52772');
      expect(recipe.name, 'Teriyaki Chicken Casserole');
      expect(recipe.category, 'Chicken');
      expect(recipe.area, 'Japanese');
      expect(recipe.thumbnailUrl, 'https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg');
      expect(recipe.youtubeUrl, 'https://www.youtube.com/watch?v=4aZr5hZXP_s');
      expect(recipe.ingredients.length, 9);
      expect(recipe.measurements.length, 9);
      expect(recipe.tags.length, 2);
      expect(recipe.tags, contains('Meat'));
      expect(recipe.tags, contains('Casserole'));
      
      // Check ingredients and measurements mapping
      expect(recipe.ingredientsWithMeasurements['soy sauce'], '3/4 cup');
      expect(recipe.ingredientsWithMeasurements['water'], '1/2 cup');
    });

    test('fromMinimalJson() should correctly parse minimal JSON data', () {
      // Act
      final recipe = Recipe.fromMinimalJson(minimalJson);

      // Assert
      expect(recipe.id, '52772');
      expect(recipe.name, 'Teriyaki Chicken Casserole');
      expect(recipe.category, 'Chicken');
      expect(recipe.area, 'Japanese');
      expect(recipe.thumbnailUrl, 'https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg');
      expect(recipe.ingredients, isEmpty);
      expect(recipe.measurements, isEmpty);
      expect(recipe.tags, isEmpty);
    });

    test('toJson() should correctly convert Recipe to JSON', () {
      // Arrange
      final recipe = Recipe.fromJson(testJson);
      
      // Act
      final jsonResult = recipe.toJson();
      
      // Assert
      expect(jsonResult['idMeal'], '52772');
      expect(jsonResult['strMeal'], 'Teriyaki Chicken Casserole');
      expect(jsonResult['strCategory'], 'Chicken');
      expect(jsonResult['strArea'], 'Japanese');
      expect(jsonResult['strMealThumb'], 'https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg');
      expect(jsonResult['strYoutube'], 'https://www.youtube.com/watch?v=4aZr5hZXP_s');
      expect(jsonResult['tags'], 'Meat,Casserole');
    });

    test('getIngredient() and getMeasurement() should return correct values', () {
      // Arrange
      final recipe = Recipe.fromJson(testJson);
      
      // Act & Assert
      expect(recipe.getIngredient(1), 'soy sauce');
      expect(recipe.getMeasurement(1), '3/4 cup');
      expect(recipe.getIngredient(10), null); // Empty ingredient
      expect(recipe.getIngredient(21), null); // Out of range
    });

    test('copyWith() should correctly create a copy with updated values', () {
      // Arrange
      final recipe = Recipe.fromJson(testJson);
      
      // Act
      final updatedRecipe = recipe.copyWith(
        name: 'Updated Recipe Name',
        category: 'Updated Category',
      );
      
      // Assert
      expect(updatedRecipe.id, recipe.id); // Unchanged
      expect(updatedRecipe.name, 'Updated Recipe Name'); // Changed
      expect(updatedRecipe.category, 'Updated Category'); // Changed
      expect(updatedRecipe.area, recipe.area); // Unchanged
      expect(updatedRecipe.ingredients, recipe.ingredients); // Unchanged
    });

    test('equality check should work correctly', () {
      // Arrange
      final recipe1 = Recipe.fromJson(testJson);
      final recipe2 = Recipe.fromJson(testJson);
      final recipe3 = Recipe.fromJson(testJson).copyWith(name: 'Different Name');
      
      // Assert
      expect(recipe1, recipe2); // Same data, should be equal
      expect(recipe1, isNot(recipe3)); // Different name, should not be equal
    });

    test('should handle null or empty values gracefully', () {
      // Arrange
      final incompleteJson = {
        'idMeal': '52772',
        'strMeal': null,
        'strCategory': '',
      };
      
      // Act
      final recipe = Recipe.fromJson(incompleteJson);
      
      // Assert
      expect(recipe.id, '52772');
      expect(recipe.name, '');
      expect(recipe.category, '');
      expect(recipe.area, '');
      expect(recipe.ingredients, isEmpty);
      expect(recipe.measurements, isEmpty);
    });
  });
}
