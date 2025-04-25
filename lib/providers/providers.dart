import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import '../data/api/recipe_api_service.dart';
import '../data/local/favorites_local_storage.dart';
import '../data/repositories/recipe_repository.dart';
import '../models/category.dart' as app_models;
import '../models/pagination.dart';
import '../models/recipe.dart';
import '../utils/image_utils.dart';
import '../utils/api_cache_manager.dart';
import 'paginated_recipes_provider.dart';

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

/// Provider for the image cache manager
final imageCacheProvider = Provider<RecipeImageCacheManager>((ref) {
  return RecipeImageCacheManager();
});

/// Provider for the API cache manager
final apiCacheProvider = Provider<ApiCacheManager>((ref) {
  return ApiCacheManager();
});

// State providers for UI state
final searchQueryProvider = StateProvider<String>((ref) => '');
final categoryFilterProvider = StateProvider<String?>((ref) => null);
final areaFilterProvider = StateProvider<String?>((ref) => null);

/// Provider for pagination state
final paginationStateProvider = StateProvider<PaginationState>((ref) {
  return const PaginationState(pageSize: 10);
});

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

/// Paginated recipes provider for efficient loading of large lists
final paginatedRecipesProvider = StateNotifierProvider<PaginatedRecipesNotifier, PaginatedResult<Recipe>>((ref) {
  final repository = ref.watch(recipeRepositoryProvider);
  return PaginatedRecipesNotifier(repository);
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

// Settings providers
final clearFavoritesProvider = Provider<Future<void> Function()>((ref) {
  return () async {
    final repository = ref.read(recipeRepositoryProvider);
    await repository.clearAllFavorites();
    // Refresh the favorites providers
    ref.invalidate(favoriteIdsProvider);
    ref.invalidate(favoriteRecipesProvider);
  };
});

/// Provider for clearing API cache
final clearApiCacheProvider = Provider<Future<bool> Function()>((ref) {
  return () async {
    final repository = ref.read(recipeRepositoryProvider);
    return repository.clearApiCache();
  };
});
