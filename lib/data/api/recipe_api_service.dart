import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../models/category.dart' as app_models;
import '../../models/pagination.dart';
import '../../models/recipe.dart';
import '../../utils/api_cache_manager.dart';

/// Service class for interacting with TheMealDB API
class RecipeApiService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';
  final Dio _dio;
  final Logger _logger = Logger();
  final ApiCacheManager _cacheManager = ApiCacheManager();

  RecipeApiService({Dio? dio}) : _dio = dio ?? Dio();

  /// Fetches a paginated list of recipes by category
  /// [category] - Category name to filter recipes
  /// [pagination] - Pagination state for the request
  Future<PaginatedResult<Recipe>> getRecipesByCategoryPaginated(
    String category,
    PaginationState pagination,
  ) async {
    try {
      // Check cache first
      final cacheKey = 'recipes_category_${category}_${pagination.page}';
      final cachedData = await _cacheManager.getCachedData(cacheKey);
      
      if (cachedData != null) {
        _logger.d('Using cached data for $cacheKey');
        return PaginatedResult<Recipe>(
          items: List<Recipe>.from(
            (cachedData['meals'] ?? []).map((meal) => Recipe.fromMinimalJson(meal)),
          ),
          pagination: pagination.loadingComplete(
            hasMoreItems: (cachedData['meals'] ?? []).length >= pagination.pageSize,
          ),
        );
      }
      
      // If not in cache, fetch from API
      final response = await _dio.get('$_baseUrl/filter.php', 
        queryParameters: {'c': category});
      
      _logger.d('Fetched recipes by category: $category');
      
      final data = response.data;
      if (data == null || data['meals'] == null) {
        return PaginatedResult.empty<Recipe>(pagination: pagination.loadingComplete(hasMoreItems: false));
      }
      
      // Cache the response
      await _cacheManager.cacheData(cacheKey, data);
      
      // Process all meals from the API
      final allMeals = List<dynamic>.from(data['meals'] ?? []);
      
      // Apply pagination manually since the API doesn't support it natively
      final paginatedMeals = _paginateResults(allMeals, pagination);
      
      // Check if there are more items
      final hasMore = (pagination.page + 1) * pagination.pageSize < allMeals.length;
      
      return PaginatedResult<Recipe>(
        items: List<Recipe>.from(
          paginatedMeals.map((meal) => Recipe.fromMinimalJson(meal)),
        ),
        pagination: pagination.loadingComplete(hasMoreItems: hasMore),
      );
    } catch (e) {
      _logger.e('Error fetching recipes by category: $e');
      throw _handleError(e);
    }
  }

  /// Fetches a list of recipes by category
  /// [category] - Category name to filter recipes
  Future<List<Recipe>> getRecipesByCategory(String category) async {
    try {
      // Check cache first
      final cacheKey = 'recipes_category_$category';
      final cachedData = await _cacheManager.getCachedData(cacheKey);
      
      if (cachedData != null) {
        _logger.d('Using cached data for $cacheKey');
        return List<Recipe>.from(
          (cachedData['meals'] ?? []).map((meal) => Recipe.fromMinimalJson(meal)),
        );
      }
      
      final response = await _dio.get('$_baseUrl/filter.php', 
        queryParameters: {'c': category});
      
      _logger.d('Fetched recipes by category: $category');
      
      final data = response.data;
      if (data == null || data['meals'] == null) {
        return [];
      }
      
      // Cache the response
      await _cacheManager.cacheData(cacheKey, data);
      
      return List<Recipe>.from(
        data['meals'].map((meal) => Recipe.fromMinimalJson(meal)),
      );
    } catch (e) {
      _logger.e('Error fetching recipes by category: $e');
      throw _handleError(e);
    }
  }

  /// Fetches a list of all available categories
  Future<List<app_models.Category>> getCategories() async {
    try {
      // Check cache first
      final cacheKey = 'categories';
      final cachedData = await _cacheManager.getCachedData(cacheKey);
      
      if (cachedData != null) {
        _logger.d('Using cached data for $cacheKey');
        return List<app_models.Category>.from(
          (cachedData['categories'] ?? []).map((category) => app_models.Category.fromJson(category)),
        );
      }
      
      final response = await _dio.get('$_baseUrl/categories.php');
      
      _logger.d('Fetched all categories');
      
      final data = response.data;
      if (data == null || data['categories'] == null) {
        return [];
      }
      
      // Cache the response with a longer duration since categories rarely change
      await _cacheManager.cacheData(cacheKey, data, duration: const Duration(days: 7));
      
      return List<app_models.Category>.from(
        data['categories'].map((category) => app_models.Category.fromJson(category)),
      );
    } catch (e) {
      _logger.e('Error fetching categories: $e');
      throw _handleError(e);
    }
  }

  /// Fetches detailed recipe information by ID
  /// [id] - Recipe ID to fetch details for
  Future<Recipe?> getRecipeById(String id) async {
    try {
      // Check cache first
      final cacheKey = 'recipe_$id';
      final cachedData = await _cacheManager.getCachedData(cacheKey);
      
      if (cachedData != null) {
        _logger.d('Using cached data for $cacheKey');
        if (cachedData['meals'] == null || cachedData['meals'].isEmpty) {
          return null;
        }
        return Recipe.fromJson(cachedData['meals'][0]);
      }
      
      final response = await _dio.get('$_baseUrl/lookup.php', 
        queryParameters: {'i': id});
      
      _logger.d('Fetched recipe details for ID: $id');
      
      final data = response.data;
      if (data == null || data['meals'] == null || data['meals'].isEmpty) {
        return null;
      }
      
      // Cache the response
      await _cacheManager.cacheData(cacheKey, data);
      
      return Recipe.fromJson(data['meals'][0]);
    } catch (e) {
      _logger.e('Error fetching recipe by ID: $e');
      throw _handleError(e);
    }
  }

  /// Searches for recipes by name with pagination
  /// [query] - Search term to find matching recipes
  /// [pagination] - Pagination state for the request
  Future<PaginatedResult<Recipe>> searchRecipesPaginated(
    String query,
    PaginationState pagination,
  ) async {
    try {
      if (query.isEmpty) {
        return PaginatedResult.empty<Recipe>(pagination: pagination.loadingComplete(hasMoreItems: false));
      }
      
      // Check cache first
      final cacheKey = 'search_${query.toLowerCase()}_${pagination.page}';
      final cachedData = await _cacheManager.getCachedData(cacheKey);
      
      if (cachedData != null) {
        _logger.d('Using cached data for $cacheKey');
        return PaginatedResult<Recipe>(
          items: List<Recipe>.from(
            (cachedData['meals'] ?? []).map((meal) => Recipe.fromMinimalJson(meal)),
          ),
          pagination: pagination.loadingComplete(
            hasMoreItems: (cachedData['meals'] ?? []).length >= pagination.pageSize,
          ),
        );
      }
      
      final response = await _dio.get('$_baseUrl/search.php', 
        queryParameters: {'s': query});
      
      _logger.d('Searched recipes with query: $query');
      
      final data = response.data;
      if (data == null || data['meals'] == null) {
        return PaginatedResult.empty<Recipe>(pagination: pagination.loadingComplete(hasMoreItems: false));
      }
      
      // Cache the response
      await _cacheManager.cacheData(cacheKey, data);
      
      // Process all meals from the API
      final allMeals = List<dynamic>.from(data['meals'] ?? []);
      
      // Apply pagination manually since the API doesn't support it natively
      final paginatedMeals = _paginateResults(allMeals, pagination);
      
      // Check if there are more items
      final hasMore = (pagination.page + 1) * pagination.pageSize < allMeals.length;
      
      return PaginatedResult<Recipe>(
        items: List<Recipe>.from(
          paginatedMeals.map((meal) => Recipe.fromMinimalJson(meal)),
        ),
        pagination: pagination.loadingComplete(hasMoreItems: hasMore),
      );
    } catch (e) {
      _logger.e('Error searching recipes: $e');
      throw _handleError(e);
    }
  }

  /// Searches for recipes by name
  /// [query] - Search term to find matching recipes
  Future<List<Recipe>> searchRecipes(String query) async {
    try {
      if (query.isEmpty) {
        return [];
      }
      
      // Check cache first
      final cacheKey = 'search_${query.toLowerCase()}';
      final cachedData = await _cacheManager.getCachedData(cacheKey);
      
      if (cachedData != null) {
        _logger.d('Using cached data for $cacheKey');
        return List<Recipe>.from(
          (cachedData['meals'] ?? []).map((meal) => Recipe.fromMinimalJson(meal)),
        );
      }
      
      final response = await _dio.get('$_baseUrl/search.php', 
        queryParameters: {'s': query});
      
      _logger.d('Searched recipes with query: $query');
      
      final data = response.data;
      if (data == null || data['meals'] == null) {
        return [];
      }
      
      // Cache the response
      await _cacheManager.cacheData(cacheKey, data);
      
      return List<Recipe>.from(
        data['meals'].map((meal) => Recipe.fromMinimalJson(meal)),
      );
    } catch (e) {
      _logger.e('Error searching recipes: $e');
      throw _handleError(e);
    }
  }

  /// Fetches a list of recipes by area (cuisine) with pagination
  /// [area] - Area/cuisine name to filter recipes
  /// [pagination] - Pagination state for the request
  Future<PaginatedResult<Recipe>> getRecipesByAreaPaginated(
    String area,
    PaginationState pagination,
  ) async {
    try {
      // Check cache first
      final cacheKey = 'recipes_area_${area}_${pagination.page}';
      final cachedData = await _cacheManager.getCachedData(cacheKey);
      
      if (cachedData != null) {
        _logger.d('Using cached data for $cacheKey');
        return PaginatedResult<Recipe>(
          items: List<Recipe>.from(
            (cachedData['meals'] ?? []).map((meal) => Recipe.fromMinimalJson(meal)),
          ),
          pagination: pagination.loadingComplete(
            hasMoreItems: (cachedData['meals'] ?? []).length >= pagination.pageSize,
          ),
        );
      }
      
      final response = await _dio.get('$_baseUrl/filter.php', 
        queryParameters: {'a': area});
      
      _logger.d('Fetched recipes by area: $area');
      
      final data = response.data;
      if (data == null || data['meals'] == null) {
        return PaginatedResult.empty<Recipe>(pagination: pagination.loadingComplete(hasMoreItems: false));
      }
      
      // Cache the response
      await _cacheManager.cacheData(cacheKey, data);
      
      // Process all meals from the API
      final allMeals = List<dynamic>.from(data['meals'] ?? []);
      
      // Apply pagination manually since the API doesn't support it natively
      final paginatedMeals = _paginateResults(allMeals, pagination);
      
      // Check if there are more items
      final hasMore = (pagination.page + 1) * pagination.pageSize < allMeals.length;
      
      return PaginatedResult<Recipe>(
        items: List<Recipe>.from(
          paginatedMeals.map((meal) => Recipe.fromMinimalJson(meal)),
        ),
        pagination: pagination.loadingComplete(hasMoreItems: hasMore),
      );
    } catch (e) {
      _logger.e('Error fetching recipes by area: $e');
      throw _handleError(e);
    }
  }

  /// Fetches a list of recipes by area (cuisine)
  /// [area] - Area/cuisine name to filter recipes
  Future<List<Recipe>> getRecipesByArea(String area) async {
    try {
      // Check cache first
      final cacheKey = 'recipes_area_$area';
      final cachedData = await _cacheManager.getCachedData(cacheKey);
      
      if (cachedData != null) {
        _logger.d('Using cached data for $cacheKey');
        return List<Recipe>.from(
          (cachedData['meals'] ?? []).map((meal) => Recipe.fromMinimalJson(meal)),
        );
      }
      
      final response = await _dio.get('$_baseUrl/filter.php', 
        queryParameters: {'a': area});
      
      _logger.d('Fetched recipes by area: $area');
      
      final data = response.data;
      if (data == null || data['meals'] == null) {
        return [];
      }
      
      // Cache the response
      await _cacheManager.cacheData(cacheKey, data);
      
      return List<Recipe>.from(
        data['meals'].map((meal) => Recipe.fromMinimalJson(meal)),
      );
    } catch (e) {
      _logger.e('Error fetching recipes by area: $e');
      throw _handleError(e);
    }
  }

  /// Fetches a random recipe
  Future<Recipe?> getRandomRecipe() async {
    try {
      final response = await _dio.get('$_baseUrl/random.php');
      
      _logger.d('Fetched random recipe');
      
      final data = response.data;
      if (data == null || data['meals'] == null || data['meals'].isEmpty) {
        return null;
      }
      
      // We don't cache random recipes since they should be different each time
      
      return Recipe.fromJson(data['meals'][0]);
    } catch (e) {
      _logger.e('Error fetching random recipe: $e');
      throw _handleError(e);
    }
  }

  /// Clears all API response caches
  Future<bool> clearCache() async {
    return _cacheManager.clearAllCache();
  }

  /// Applies pagination to a list of results manually
  /// This is needed because TheMealDB API doesn't support pagination natively
  List<dynamic> _paginateResults(List<dynamic> allResults, PaginationState pagination) {
    final startIndex = pagination.offset;
    final endIndex = startIndex + pagination.pageSize;
    
    if (startIndex >= allResults.length) {
      return [];
    }
    
    return allResults.sublist(
      startIndex, 
      endIndex > allResults.length ? allResults.length : endIndex,
    );
  }

  /// Handles API errors and converts them to user-friendly exceptions
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return TimeoutException('Connection timed out. Please try again.');
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 429) {
            return RateLimitException('API rate limit exceeded. Please try again later.');
          }
          return ApiException('Server error: ${statusCode ?? 'Unknown'}');
        case DioExceptionType.connectionError:
          return NetworkException('No internet connection. Please check your network.');
        default:
          return ApiException('An unexpected error occurred: ${error.message}');
      }
    }
    return ApiException('An unexpected error occurred: $error');
  }
}

/// Custom exceptions for API errors
class ApiException implements Exception {
  final String message;
  ApiException(this.message);
  @override
  String toString() => message;
}

class NetworkException extends ApiException {
  NetworkException(String message) : super(message);
}

class TimeoutException extends ApiException {
  TimeoutException(String message) : super(message);
}

class RateLimitException extends ApiException {
  RateLimitException(String message) : super(message);
}
