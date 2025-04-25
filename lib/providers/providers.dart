import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../data/api/recipe_api_service.dart';
import '../data/local/favorites_local_storage.dart';
import '../data/repositories/recipe_repository.dart';
import '../models/category.dart' as app_models;
import '../models/recipe.dart';

// Service providers
final dioProvider = Provider<Dio>((ref) {
  return Dio()
    ..interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      error: true,
      request: false,
      requestHeader: false,
      responseHeader: false,
    ));
});

final recipeApiServiceProvider = Provider<RecipeApiService>((ref) {
  final dio = ref.watch(dioProvider);
  return RecipeApiService(dio: dio);
});

final favoritesLocalStorageProvider = Provider<FavoritesLocalStorage>((ref) {
  return FavoritesLocalStorage();
});

final recipeRepositoryProvider = Provider<RecipeRepository>((ref) {
  final apiService = ref.watch(recipeApiServiceProvider);
  final localStorage = ref.watch(favoritesLocalStorageProvider);
  return RecipeRepository(
    apiService: apiService,
    localStorage: localStorage,
  );
});

// State providers for UI state
final searchQueryProvider = StateProvider<String>((ref) => '');
final categoryFilterProvider = StateProvider<String?>((ref) => null);
final areaFilterProvider = StateProvider<String?>((ref) => null);

// Data providers
final categoriesProvider = FutureProvider<List<app_models.Category>>((ref) async {
  final repository = ref.watch(recipeRepositoryProvider);
  return repository.getCategories();
});

final recipesByCategoryProvider = FutureProvider.family<List<Recipe>, String>((ref, category) async {
  final repository = ref.watch(recipeRepositoryProvider);
  return repository.getRecipesByCategory(category);
});

final recipesByAreaProvider = FutureProvider.family<List<Recipe>, String>((ref, area) async {
  final repository = ref.watch(recipeRepositoryProvider);
  return repository.getRecipesByArea(area);
});

final recipeDetailsProvider = FutureProvider.family<Recipe?, String>((ref, id) async {
  final repository = ref.watch(recipeRepositoryProvider);
  return repository.getRecipeById(id);
});

final searchRecipesProvider = FutureProvider.family<List<Recipe>, String>((ref, query) async {
  if (query.isEmpty) {
    return [];
  }
  final repository = ref.watch(recipeRepositoryProvider);
  return repository.searchRecipes(query);
});

final randomRecipeProvider = FutureProvider<Recipe?>((ref) async {
  final repository = ref.watch(recipeRepositoryProvider);
  return repository.getRandomRecipe();
});

// Combined providers
final filteredRecipesProvider = FutureProvider<List<Recipe>>((ref) async {
  final searchQuery = ref.watch(searchQueryProvider);
  final categoryFilter = ref.watch(categoryFilterProvider);
  final areaFilter = ref.watch(areaFilterProvider);

  final repository = ref.watch(recipeRepositoryProvider);

  // If we have a search query, prioritize that
  if (searchQuery.isNotEmpty) {
    return repository.searchRecipes(searchQuery);
  }

  // Otherwise, filter by category or area if set
  if (categoryFilter != null) {
    return repository.getRecipesByCategory(categoryFilter);
  }

  if (areaFilter != null) {
    return repository.getRecipesByArea(areaFilter);
  }

  // If no filters are active, return a random selection or featured recipes
  try {
    // Default to showing recipes from the "Beef" category as a starting point
    return repository.getRecipesByCategory('Beef');
  } catch (e) {
    // Fallback to an empty list if there's an error
    return [];
  }
});

// Favorites providers
final favoriteIdsProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(recipeRepositoryProvider);
  return repository.getFavoriteIds();
});

final favoriteRecipesProvider = FutureProvider<List<Recipe>>((ref) async {
  final repository = ref.watch(recipeRepositoryProvider);
  return repository.getFavoriteRecipes();
});

final isFavoriteProvider = FutureProvider.family<bool, String>((ref, recipeId) async {
  final repository = ref.watch(recipeRepositoryProvider);
  return repository.isFavorite(recipeId);
});
