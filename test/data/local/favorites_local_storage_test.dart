import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:recipe_book/data/local/favorites_local_storage.dart';
import 'package:recipe_book/models/recipe.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('FavoritesLocalStorage Tests', () {
    late FavoritesLocalStorage localStorage;
    late Map<String, Object> prefsMap;

    setUp(() {
      // Create a map to hold the mock SharedPreferences data
      prefsMap = {};
      
      // Set up SharedPreferences mock
      SharedPreferences.setMockInitialValues(prefsMap);
      
      // Create the local storage instance
      localStorage = FavoritesLocalStorage();
    });

    // Helper function to create a test recipe
    Recipe createTestRecipe() {
      return Recipe(
        id: '52772',
        name: 'Teriyaki Chicken Casserole',
        category: 'Chicken',
        area: 'Japanese',
        instructions: 'Test instructions',
        thumbnailUrl: 'https://example.com/image.jpg',
        youtubeUrl: 'https://youtube.com/watch?v=123',
        originalData: {'idMeal': '52772', 'strMeal': 'Teriyaki Chicken Casserole'},
        ingredients: ['Chicken', 'Sauce'],
        measurements: ['1 pound', '1/2 cup'],
        ingredientsWithMeasurements: {'Chicken': '1 pound', 'Sauce': '1/2 cup'},
        tags: ['Meat', 'Casserole'],
      );
    }

    group('getFavoriteIds', () {
      test('should return empty list when no favorites exist', () async {
        // Act
        final result = await localStorage.getFavoriteIds();
        
        // Assert
        expect(result, isEmpty);
      });

      test('should return list of favorite IDs when favorites exist', () async {
        // Arrange
        prefsMap['favorite_recipes'] = ['1', '2', '3'];
        SharedPreferences.setMockInitialValues(prefsMap);
        
        // Act
        final result = await localStorage.getFavoriteIds();
        
        // Assert
        expect(result, ['1', '2', '3']);
      });
    });

    group('isFavorite', () {
      test('should return true when recipe is in favorites', () async {
        // Arrange
        prefsMap['favorite_recipes'] = ['1', '2', '3'];
        SharedPreferences.setMockInitialValues(prefsMap);
        
        // Act
        final result = await localStorage.isFavorite('2');
        
        // Assert
        expect(result, isTrue);
      });

      test('should return false when recipe is not in favorites', () async {
        // Arrange
        prefsMap['favorite_recipes'] = ['1', '2', '3'];
        SharedPreferences.setMockInitialValues(prefsMap);
        
        // Act
        final result = await localStorage.isFavorite('4');
        
        // Assert
        expect(result, isFalse);
      });
    });

    group('addToFavorites', () {
      test('should add recipe ID to favorites list', () async {
        // Arrange
        prefsMap['favorite_recipes'] = ['1', '2'];
        SharedPreferences.setMockInitialValues(prefsMap);
        final recipe = createTestRecipe();
        
        // Act
        await localStorage.addToFavorites(recipe);
        
        // Get the updated SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final updatedFavorites = prefs.getStringList('favorite_recipes');
        
        // Assert
        expect(updatedFavorites, contains('52772'));
        expect(updatedFavorites?.length, 3);
      });

      test('should not add duplicate recipe ID to favorites list', () async {
        // Arrange
        prefsMap['favorite_recipes'] = ['1', '52772'];
        SharedPreferences.setMockInitialValues(prefsMap);
        final recipe = createTestRecipe();
        
        // Act
        await localStorage.addToFavorites(recipe);
        
        // Get the updated SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final updatedFavorites = prefs.getStringList('favorite_recipes');
        
        // Assert
        expect(updatedFavorites, ['1', '52772']);
        expect(updatedFavorites?.length, 2);
      });

      test('should store recipe details in local storage', () async {
        // Arrange
        prefsMap['favorite_recipes'] = ['1'];
        SharedPreferences.setMockInitialValues(prefsMap);
        final recipe = createTestRecipe();
        
        // Act
        await localStorage.addToFavorites(recipe);
        
        // Get the updated SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final recipeDetailsJson = prefs.getString('recipe_details');
        
        // Assert
        expect(recipeDetailsJson, isNotNull);
        final recipeDetailsMap = json.decode(recipeDetailsJson!) as Map<String, dynamic>;
        expect(recipeDetailsMap.containsKey('52772'), isTrue);
      });
    });

    group('removeFromFavorites', () {
      test('should remove recipe ID from favorites list', () async {
        // Arrange
        prefsMap['favorite_recipes'] = ['1', '2', '3'];
        SharedPreferences.setMockInitialValues(prefsMap);
        
        // Act
        await localStorage.removeFromFavorites('2');
        
        // Get the updated SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final updatedFavorites = prefs.getStringList('favorite_recipes');
        
        // Assert
        expect(updatedFavorites, ['1', '3']);
        expect(updatedFavorites?.length, 2);
      });
    });

    group('getRecipeById', () {
      test('should return null when recipe details do not exist', () async {
        // Act
        final result = await localStorage.getRecipeById('1');
        
        // Assert
        expect(result, isNull);
      });

      test('should return null when recipe ID is not found in details', () async {
        // Arrange
        final recipeDetailsMap = {'2': createTestRecipe().toJson()};
        prefsMap['recipe_details'] = json.encode(recipeDetailsMap);
        SharedPreferences.setMockInitialValues(prefsMap);
        
        // Act
        final result = await localStorage.getRecipeById('1');
        
        // Assert
        expect(result, isNull);
      });

      test('should return recipe when recipe ID is found in details', () async {
        // Arrange
        final recipe = createTestRecipe();
        final recipeDetailsMap = {'52772': recipe.toJson()};
        prefsMap['recipe_details'] = json.encode(recipeDetailsMap);
        SharedPreferences.setMockInitialValues(prefsMap);
        
        // Act
        final result = await localStorage.getRecipeById('52772');
        
        // Assert
        expect(result, isNotNull);
        expect(result?.id, '52772');
        expect(result?.name, 'Teriyaki Chicken Casserole');
      });
    });

    group('clearFavorites', () {
      test('should clear favorites list', () async {
        // Arrange
        prefsMap['favorite_recipes'] = ['1', '2', '3'];
        SharedPreferences.setMockInitialValues(prefsMap);
        
        // Act
        await localStorage.clearFavorites();
        
        // Get the updated SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final updatedFavorites = prefs.getStringList('favorite_recipes');
        
        // Assert
        expect(updatedFavorites, isEmpty);
      });
    });
  });
}
