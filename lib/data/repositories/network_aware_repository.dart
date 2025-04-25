import 'package:recipe_book/data/repositories/recipe_repository.dart';
import 'package:recipe_book/models/recipe.dart';
import 'package:recipe_book/models/category.dart';
import 'package:recipe_book/models/pagination.dart';
import 'package:recipe_book/utils/connectivity_service.dart';
import 'package:recipe_book/utils/api_cache_manager.dart';

/// A repository wrapper that is aware of network connectivity status
/// and can provide cached data when offline
class NetworkAwareRepository {
  final RecipeRepository _repository;
  final ConnectivityService _connectivityService;
  final ApiCacheManager _cacheManager;

  NetworkAwareRepository({
    required RecipeRepository repository,
    required ConnectivityService connectivityService,
    required ApiCacheManager cacheManager,
  })  : _repository = repository,
        _connectivityService = connectivityService,
        _cacheManager = cacheManager;

  /// Get a list of all recipe categories with offline support
  Future<List<Category>> getCategories() async {
    try {
      final isConnected = await _connectivityService.isConnected();
      
      if (isConnected) {
        // If online, fetch from API and update cache
        final categories = await _repository.getCategories();
        await _cacheManager.cacheData('categories', categories);
        return categories;
      } else {
        // If offline, try to get from cache
        final cachedCategories = await _cacheManager.getCachedData('categories');
        if (cachedCategories != null) {
          return cachedCategories as List<Category>;
        }
        // If no cache, rethrow with offline message
        throw Exception('No internet connection and no cached data available');
      }
    } catch (e) {
      // Check if we have cached data as fallback
      final cachedCategories = await _cacheManager.getCachedData('categories');
      if (cachedCategories != null) {
        return cachedCategories as List<Category>;
      }
      rethrow;
    }
  }

  /// Get recipes by category with offline support
  Future<List<Recipe>> getRecipesByCategory(String category) async {
    try {
      final isConnected = await _connectivityService.isConnected();
      final cacheKey = 'category_$category';
      
      if (isConnected) {
        // If online, fetch from API and update cache
        final recipes = await _repository.getRecipesByCategory(category);
        await _cacheManager.cacheData(cacheKey, recipes);
        return recipes;
      } else {
        // If offline, try to get from cache
        final cachedRecipes = await _cacheManager.getCachedData(cacheKey);
        if (cachedRecipes != null) {
          return cachedRecipes as List<Recipe>;
        }
        // If no cache, rethrow with offline message
        throw Exception('No internet connection and no cached data available');
      }
    } catch (e) {
      // Check if we have cached data as fallback
      final cacheKey = 'category_$category';
      final cachedRecipes = await _cacheManager.getCachedData(cacheKey);
      if (cachedRecipes != null) {
        return cachedRecipes as List<Recipe>;
      }
      rethrow;
    }
  }

  /// Get recipes by category with pagination
  Future<PaginatedResult<Recipe>> getRecipesByCategoryPaginated(
    String category,
    PaginationState pagination,
  ) async {
    try {
      final isConnected = await _connectivityService.isConnected();
      final cacheKey = 'category_paginated_${category}_${pagination.page}';
      
      if (isConnected) {
        final result = await _repository.getRecipesByCategoryPaginated(category, pagination);
        await _cacheManager.cacheData(cacheKey, result);
        return result;
      } else {
        final cachedResult = await _cacheManager.getCachedData(cacheKey);
        if (cachedResult != null) {
          return cachedResult as PaginatedResult<Recipe>;
        }
        throw Exception('No internet connection and no cached data available');
      }
    } catch (e) {
      final cacheKey = 'category_paginated_${category}_${pagination.page}';
      final cachedResult = await _cacheManager.getCachedData(cacheKey);
      if (cachedResult != null) {
        return cachedResult as PaginatedResult<Recipe>;
      }
      rethrow;
    }
  }

  /// Get recipes by area with offline support
  Future<List<Recipe>> getRecipesByArea(String area) async {
    try {
      final isConnected = await _connectivityService.isConnected();
      final cacheKey = 'area_$area';
      
      if (isConnected) {
        // If online, fetch from API and update cache
        final recipes = await _repository.getRecipesByArea(area);
        await _cacheManager.cacheData(cacheKey, recipes);
        return recipes;
      } else {
        // If offline, try to get from cache
        final cachedRecipes = await _cacheManager.getCachedData(cacheKey);
        if (cachedRecipes != null) {
          return cachedRecipes as List<Recipe>;
        }
        // If no cache, rethrow with offline message
        throw Exception('No internet connection and no cached data available');
      }
    } catch (e) {
      // Check if we have cached data as fallback
      final cacheKey = 'area_$area';
      final cachedRecipes = await _cacheManager.getCachedData(cacheKey);
      if (cachedRecipes != null) {
        return cachedRecipes as List<Recipe>;
      }
      rethrow;
    }
  }

  /// Get recipes by area with pagination
  Future<PaginatedResult<Recipe>> getRecipesByAreaPaginated(
    String area,
    PaginationState pagination,
  ) async {
    try {
      final isConnected = await _connectivityService.isConnected();
      final cacheKey = 'area_paginated_${area}_${pagination.page}';
      
      if (isConnected) {
        final result = await _repository.getRecipesByAreaPaginated(area, pagination);
        await _cacheManager.cacheData(cacheKey, result);
        return result;
      } else {
        final cachedResult = await _cacheManager.getCachedData(cacheKey);
        if (cachedResult != null) {
          return cachedResult as PaginatedResult<Recipe>;
        }
        throw Exception('No internet connection and no cached data available');
      }
    } catch (e) {
      final cacheKey = 'area_paginated_${area}_${pagination.page}';
      final cachedResult = await _cacheManager.getCachedData(cacheKey);
      if (cachedResult != null) {
        return cachedResult as PaginatedResult<Recipe>;
      }
      rethrow;
    }
  }

  /// Get a recipe by ID with offline support
  Future<Recipe?> getRecipeById(String id) async {
    try {
      final isConnected = await _connectivityService.isConnected();
      final cacheKey = 'recipe_$id';
      
      if (isConnected) {
        // If online, fetch from API and update cache
        final recipe = await _repository.getRecipeById(id);
        if (recipe != null) {
          await _cacheManager.cacheData(cacheKey, recipe);
        }
        return recipe;
      } else {
        // If offline, try to get from cache
        final cachedRecipe = await _cacheManager.getCachedData(cacheKey);
        return cachedRecipe as Recipe?;
      }
    } catch (e) {
      // Check if we have cached data as fallback
      final cacheKey = 'recipe_$id';
      final cachedRecipe = await _cacheManager.getCachedData(cacheKey);
      if (cachedRecipe != null) {
        return cachedRecipe as Recipe;
      }
      rethrow;
    }
  }

  /// Search recipes with offline support
  Future<List<Recipe>> searchRecipes(String query) async {
    try {
      final isConnected = await _connectivityService.isConnected();
      final cacheKey = 'search_$query';
      
      if (isConnected) {
        // If online, fetch from API and update cache
        final recipes = await _repository.searchRecipes(query);
        await _cacheManager.cacheData(cacheKey, recipes);
        return recipes;
      } else {
        // If offline, try to get from cache
        final cachedRecipes = await _cacheManager.getCachedData(cacheKey);
        if (cachedRecipes != null) {
          return cachedRecipes as List<Recipe>;
        }
        // If no cache, return empty list for offline search
        return [];
      }
    } catch (e) {
      // Check if we have cached data as fallback
      final cacheKey = 'search_$query';
      final cachedRecipes = await _cacheManager.getCachedData(cacheKey);
      if (cachedRecipes != null) {
        return cachedRecipes as List<Recipe>;
      }
      // For search, return empty list rather than error
      return [];
    }
  }

  /// Search recipes with pagination
  Future<PaginatedResult<Recipe>> searchRecipesPaginated(
    String query,
    PaginationState pagination,
  ) async {
    try {
      final isConnected = await _connectivityService.isConnected();
      final cacheKey = 'search_paginated_${query}_${pagination.page}';
      
      if (isConnected) {
        final result = await _repository.searchRecipesPaginated(query, pagination);
        await _cacheManager.cacheData(cacheKey, result);
        return result;
      } else {
        final cachedResult = await _cacheManager.getCachedData(cacheKey);
        if (cachedResult != null) {
          return cachedResult as PaginatedResult<Recipe>;
        }
        // For search, return empty result rather than error
        return PaginatedResult<Recipe>(
          items: [],
          pagination: PaginationState(
            page: pagination.page,
            pageSize: pagination.pageSize,
            hasMore: false,
          ),
        );
      }
    } catch (e) {
      final cacheKey = 'search_paginated_${query}_${pagination.page}';
      final cachedResult = await _cacheManager.getCachedData(cacheKey);
      if (cachedResult != null) {
        return cachedResult as PaginatedResult<Recipe>;
      }
      // For search, return empty result rather than error
      return PaginatedResult<Recipe>(
        items: [],
        pagination: PaginationState(
          page: pagination.page,
          pageSize: pagination.pageSize,
          hasMore: false,
        ),
      );
    }
  }

  /// Get a random recipe with offline support
  Future<Recipe?> getRandomRecipe() async {
    try {
      final isConnected = await _connectivityService.isConnected();
      
      if (isConnected) {
        // If online, fetch from API
        return await _repository.getRandomRecipe();
      } else {
        // If offline, try to get any cached recipe
        final cachedRecipes = await _cacheManager.getCachedData('featured_recipes');
        if (cachedRecipes != null && cachedRecipes is List<Recipe> && cachedRecipes.isNotEmpty) {
          // Return a random recipe from the cached list
          cachedRecipes.shuffle();
          return cachedRecipes.first;
        }
        return null;
      }
    } catch (e) {
      // Try to get any cached recipe as fallback
      try {
        final cachedRecipes = await _cacheManager.getCachedData('featured_recipes');
        if (cachedRecipes != null && cachedRecipes is List<Recipe> && cachedRecipes.isNotEmpty) {
          cachedRecipes.shuffle();
          return cachedRecipes.first;
        }
      } catch (_) {
        // Ignore cache errors
      }
      rethrow;
    }
  }

  /// Get favorite recipes
  Future<List<Recipe>> getFavoriteRecipes() async {
    return _repository.getFavoriteRecipes();
  }

  /// Get favorite IDs
  Future<List<String>> getFavoriteIds() async {
    return _repository.getFavoriteIds();
  }

  /// Check if a recipe is a favorite
  Future<bool> isFavorite(String recipeId) async {
    return _repository.isFavorite(recipeId);
  }

  /// Add a recipe to favorites
  Future<void> addToFavorites(Recipe recipe) async {
    await _repository.addToFavorites(recipe);
  }

  /// Remove a recipe from favorites
  Future<void> removeFromFavorites(String recipeId) async {
    await _repository.removeFromFavorites(recipeId);
  }

  /// Clear all favorites
  Future<void> clearAllFavorites() async {
    await _repository.clearAllFavorites();
  }

  /// Clear API cache
  Future<bool> clearApiCache() async {
    return _repository.clearApiCache();
  }
  
  /// Checks if the user has seen the onboarding screens
  Future<bool> hasSeenOnboarding() async {
    return _repository.hasSeenOnboarding();
  }

  /// Marks the onboarding as seen
  Future<void> setOnboardingSeen() async {
    await _repository.setOnboardingSeen();
  }

  /// Resets the onboarding status (for testing purposes)
  Future<void> resetOnboardingStatus() async {
    await _repository.resetOnboardingStatus();
  }
}
