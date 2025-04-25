import 'package:dio/dio.dart';
import 'package:logger/logger.dart';

import '../../models/category.dart' as app_models;
import '../../models/recipe.dart';

/// Service class for interacting with TheMealDB API
class RecipeApiService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';
  final Dio _dio;
  final Logger _logger = Logger();

  RecipeApiService({Dio? dio}) : _dio = dio ?? Dio();

  /// Fetches a list of recipes by category
  /// [category] - Category name to filter recipes
  Future<List<Recipe>> getRecipesByCategory(String category) async {
    try {
      final response = await _dio.get('$_baseUrl/filter.php', 
        queryParameters: {'c': category});
      
      _logger.d('Fetched recipes by category: $category');
      
      final data = response.data;
      if (data == null || data['meals'] == null) {
        return [];
      }
      
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
      final response = await _dio.get('$_baseUrl/categories.php');
      
      _logger.d('Fetched all categories');
      
      final data = response.data;
      if (data == null || data['categories'] == null) {
        return [];
      }
      
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
      final response = await _dio.get('$_baseUrl/lookup.php', 
        queryParameters: {'i': id});
      
      _logger.d('Fetched recipe details for ID: $id');
      
      final data = response.data;
      if (data == null || data['meals'] == null || data['meals'].isEmpty) {
        return null;
      }
      
      return Recipe.fromJson(data['meals'][0]);
    } catch (e) {
      _logger.e('Error fetching recipe by ID: $e');
      throw _handleError(e);
    }
  }

  /// Searches for recipes by name
  /// [query] - Search term to find matching recipes
  Future<List<Recipe>> searchRecipes(String query) async {
    try {
      final response = await _dio.get('$_baseUrl/search.php', 
        queryParameters: {'s': query});
      
      _logger.d('Searched recipes with query: $query');
      
      final data = response.data;
      if (data == null || data['meals'] == null) {
        return [];
      }
      
      return List<Recipe>.from(
        data['meals'].map((meal) => Recipe.fromMinimalJson(meal)),
      );
    } catch (e) {
      _logger.e('Error searching recipes: $e');
      throw _handleError(e);
    }
  }

  /// Fetches a list of recipes by area (cuisine)
  /// [area] - Area/cuisine name to filter recipes
  Future<List<Recipe>> getRecipesByArea(String area) async {
    try {
      final response = await _dio.get('$_baseUrl/filter.php', 
        queryParameters: {'a': area});
      
      _logger.d('Fetched recipes by area: $area');
      
      final data = response.data;
      if (data == null || data['meals'] == null) {
        return [];
      }
      
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
      
      return Recipe.fromJson(data['meals'][0]);
    } catch (e) {
      _logger.e('Error fetching random recipe: $e');
      throw _handleError(e);
    }
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
