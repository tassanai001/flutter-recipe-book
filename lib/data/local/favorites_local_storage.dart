import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../models/recipe.dart';

/// Service class for managing favorite recipes in local storage using SharedPreferences
class FavoritesLocalStorage {
  static const String _favoritesKey = 'favorite_recipes';
  static const String _recipeDetailsKey = 'recipe_details';

  /// Gets all favorite recipe IDs from local storage
  Future<List<String>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_favoritesKey) ?? [];
  }

  /// Checks if a recipe is in favorites
  Future<bool> isFavorite(String recipeId) async {
    final favorites = await getFavoriteIds();
    return favorites.contains(recipeId);
  }

  /// Adds a recipe to favorites
  /// Stores both the ID in the favorites list and the recipe details for offline access
  Future<void> addToFavorites(Recipe recipe) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Add to favorites list
    final favorites = await getFavoriteIds();
    if (!favorites.contains(recipe.id)) {
      favorites.add(recipe.id);
      await prefs.setStringList(_favoritesKey, favorites);
    }
    
    // Store recipe details
    final recipeDetailsMap = prefs.getString(_recipeDetailsKey) != null
        ? json.decode(prefs.getString(_recipeDetailsKey)!) as Map<String, dynamic>
        : <String, dynamic>{};
    
    recipeDetailsMap[recipe.id] = recipe.toJson();
    await prefs.setString(_recipeDetailsKey, json.encode(recipeDetailsMap));
  }

  /// Removes a recipe from favorites
  Future<void> removeFromFavorites(String recipeId) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Remove from favorites list
    final favorites = await getFavoriteIds();
    favorites.remove(recipeId);
    await prefs.setStringList(_favoritesKey, favorites);
    
    // We keep the recipe details in case the user re-adds it later
    // This is a design choice - we could also remove the details here
  }

  /// Gets a recipe by ID from local storage
  Future<Recipe?> getRecipeById(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final recipeDetailsString = prefs.getString(_recipeDetailsKey);
    
    if (recipeDetailsString == null) {
      return null;
    }
    
    final recipeDetailsMap = json.decode(recipeDetailsString) as Map<String, dynamic>;
    final recipeJson = recipeDetailsMap[id];
    
    if (recipeJson == null) {
      return null;
    }
    
    return Recipe.fromJson(recipeJson);
  }

  /// Clears all favorites
  Future<void> clearFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_favoritesKey, []);
    // We keep the recipe details in case the user re-adds them later
  }
}
