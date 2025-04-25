import '../../models/category.dart' as app_models;
import '../../models/recipe.dart';
import '../api/recipe_api_service.dart';
import '../local/favorites_local_storage.dart';

/// Repository class for managing recipe data from both remote and local sources
class RecipeRepository {
  final RecipeApiService _apiService;
  final FavoritesLocalStorage _localStorage;

  RecipeRepository({
    required RecipeApiService apiService,
    required FavoritesLocalStorage localStorage,
  })  : _apiService = apiService,
        _localStorage = localStorage;

  /// Fetches recipes by category
  Future<List<Recipe>> getRecipesByCategory(String category) async {
    return _apiService.getRecipesByCategory(category);
  }

  /// Fetches all available categories
  Future<List<app_models.Category>> getCategories() async {
    return _apiService.getCategories();
  }

  /// Fetches detailed recipe information by ID
  Future<Recipe?> getRecipeById(String id) async {
    return _apiService.getRecipeById(id);
  }

  /// Searches for recipes by name
  Future<List<Recipe>> searchRecipes(String query) async {
    return _apiService.searchRecipes(query);
  }

  /// Fetches recipes by area/cuisine
  Future<List<Recipe>> getRecipesByArea(String area) async {
    return _apiService.getRecipesByArea(area);
  }

  /// Fetches a random recipe
  Future<Recipe?> getRandomRecipe() async {
    return _apiService.getRandomRecipe();
  }

  /// Gets all favorite recipe IDs
  Future<List<String>> getFavoriteIds() async {
    return _localStorage.getFavoriteIds();
  }

  /// Checks if a recipe is favorited
  Future<bool> isFavorite(String recipeId) async {
    return _localStorage.isFavorite(recipeId);
  }

  /// Adds a recipe to favorites
  Future<void> addToFavorites(Recipe recipe) async {
    await _localStorage.addToFavorites(recipe);
  }

  /// Removes a recipe from favorites
  Future<void> removeFromFavorites(String recipeId) async {
    await _localStorage.removeFromFavorites(recipeId);
  }

  /// Gets all favorite recipes with full details
  /// This combines local IDs with remote data to ensure up-to-date information
  Future<List<Recipe>> getFavoriteRecipes() async {
    final favoriteIds = await _localStorage.getFavoriteIds();
    final favoriteRecipes = <Recipe>[];

    // For each favorite ID, fetch the full recipe details
    for (final id in favoriteIds) {
      try {
        final recipe = await _apiService.getRecipeById(id);
        if (recipe != null) {
          favoriteRecipes.add(recipe);
        }
      } catch (e) {
        // If we can't fetch from API, try to get from local storage
        final localRecipe = await _localStorage.getRecipeById(id);
        if (localRecipe != null) {
          favoriteRecipes.add(localRecipe);
        }
      }
    }

    return favoriteRecipes;
  }
}
