import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_book/data/api/recipe_api_service.dart';
import 'package:recipe_book/models/category.dart';
import 'package:recipe_book/models/recipe.dart';

// Create mock class
class MockDio extends Mock implements Dio {}

void main() {
  group('RecipeApiService Tests', () {
    late MockDio mockDio;
    late RecipeApiService apiService;

    setUp(() {
      mockDio = MockDio();
      apiService = RecipeApiService(dio: mockDio);
    });

    group('getRecipesByCategory', () {
      test('should return list of recipes when API call is successful', () async {
        // Arrange
        final responseData = {
          'meals': [
            {
              'idMeal': '52772',
              'strMeal': 'Teriyaki Chicken Casserole',
              'strCategory': 'Chicken',
              'strArea': 'Japanese',
              'strMealThumb': 'https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg',
            }
          ]
        };

        when(() => mockDio.get(
          'https://www.themealdb.com/api/json/v1/1/filter.php',
          queryParameters: {'c': 'Chicken'}
        )).thenAnswer((_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ));

        // Act
        final result = await apiService.getRecipesByCategory('Chicken');

        // Assert
        expect(result, isA<List<Recipe>>());
        expect(result.length, 1);
        expect(result[0].id, '52772');
        expect(result[0].name, 'Teriyaki Chicken Casserole');
      });

      test('should return empty list when API returns null data', () async {
        // Arrange
        when(() => mockDio.get(
          'https://www.themealdb.com/api/json/v1/1/filter.php',
          queryParameters: {'c': 'Chicken'}
        )).thenAnswer((_) async => Response(
          data: {'meals': null},
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ));

        // Act
        final result = await apiService.getRecipesByCategory('Chicken');

        // Assert
        expect(result, isA<List<Recipe>>());
        expect(result, isEmpty);
      });

      test('should throw NetworkException when network error occurs', () async {
        // Arrange
        when(() => mockDio.get(
          'https://www.themealdb.com/api/json/v1/1/filter.php',
          queryParameters: {'c': 'Chicken'}
        )).thenThrow(DioException(
          type: DioExceptionType.connectionError,
          error: 'Connection error',
          requestOptions: RequestOptions(path: ''),
        ));

        // Act & Assert
        expect(
          () => apiService.getRecipesByCategory('Chicken'),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('getCategories', () {
      test('should return list of categories when API call is successful', () async {
        // Arrange
        final responseData = {
          'categories': [
            {
              'idCategory': '1',
              'strCategory': 'Beef',
              'strCategoryThumb': 'https://www.themealdb.com/images/category/beef.png',
              'strCategoryDescription': 'Beef is the culinary name for meat from cattle...',
            }
          ]
        };

        when(() => mockDio.get(
          'https://www.themealdb.com/api/json/v1/1/categories.php',
        )).thenAnswer((_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ));

        // Act
        final result = await apiService.getCategories();

        // Assert
        expect(result, isA<List<Category>>());
        expect(result.length, 1);
        expect(result[0].id, '1');
        expect(result[0].name, 'Beef');
      });

      test('should throw TimeoutException when request times out', () async {
        // Arrange
        when(() => mockDio.get(
          'https://www.themealdb.com/api/json/v1/1/categories.php',
        )).thenThrow(DioException(
          type: DioExceptionType.connectionTimeout,
          error: 'Connection timeout',
          requestOptions: RequestOptions(path: ''),
        ));

        // Act & Assert
        expect(
          () => apiService.getCategories(),
          throwsA(isA<TimeoutException>()),
        );
      });
    });

    group('getRecipeById', () {
      test('should return recipe details when API call is successful', () async {
        // Arrange
        final responseData = {
          'meals': [
            {
              'idMeal': '52772',
              'strMeal': 'Teriyaki Chicken Casserole',
              'strCategory': 'Chicken',
              'strArea': 'Japanese',
              'strInstructions': 'Preheat oven to 350° F...',
              'strMealThumb': 'https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg',
              'strYoutube': 'https://www.youtube.com/watch?v=4aZr5hZXP_s',
              'strIngredient1': 'soy sauce',
              'strMeasure1': '3/4 cup',
            }
          ]
        };

        when(() => mockDio.get(
          'https://www.themealdb.com/api/json/v1/1/lookup.php',
          queryParameters: {'i': '52772'}
        )).thenAnswer((_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ));

        // Act
        final result = await apiService.getRecipeById('52772');

        // Assert
        expect(result, isA<Recipe>());
        expect(result?.id, '52772');
        expect(result?.name, 'Teriyaki Chicken Casserole');
      });

      test('should return null when recipe is not found', () async {
        // Arrange
        when(() => mockDio.get(
          'https://www.themealdb.com/api/json/v1/1/lookup.php',
          queryParameters: {'i': '99999'}
        )).thenAnswer((_) async => Response(
          data: {'meals': null},
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ));

        // Act
        final result = await apiService.getRecipeById('99999');

        // Assert
        expect(result, isNull);
      });
    });

    group('searchRecipes', () {
      test('should return search results when API call is successful', () async {
        // Arrange
        final responseData = {
          'meals': [
            {
              'idMeal': '52772',
              'strMeal': 'Teriyaki Chicken Casserole',
              'strCategory': 'Chicken',
              'strArea': 'Japanese',
              'strMealThumb': 'https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg',
            }
          ]
        };

        when(() => mockDio.get(
          'https://www.themealdb.com/api/json/v1/1/search.php',
          queryParameters: {'s': 'chicken'}
        )).thenAnswer((_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ));

        // Act
        final result = await apiService.searchRecipes('chicken');

        // Assert
        expect(result, isA<List<Recipe>>());
        expect(result.length, 1);
        expect(result[0].name, 'Teriyaki Chicken Casserole');
      });

      test('should handle rate limit errors correctly', () async {
        // Arrange
        when(() => mockDio.get(
          'https://www.themealdb.com/api/json/v1/1/search.php',
          queryParameters: {'s': 'chicken'}
        )).thenThrow(DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 429,
            requestOptions: RequestOptions(path: ''),
          ),
          requestOptions: RequestOptions(path: ''),
        ));

        // Act & Assert
        expect(
          () => apiService.searchRecipes('chicken'),
          throwsA(isA<RateLimitException>()),
        );
      });
    });

    group('getRandomRecipe', () {
      test('should return a random recipe when API call is successful', () async {
        // Arrange
        final responseData = {
          'meals': [
            {
              'idMeal': '52772',
              'strMeal': 'Teriyaki Chicken Casserole',
              'strCategory': 'Chicken',
              'strArea': 'Japanese',
              'strInstructions': 'Preheat oven to 350° F...',
              'strMealThumb': 'https://www.themealdb.com/images/media/meals/wvpsxx1468256321.jpg',
            }
          ]
        };

        when(() => mockDio.get(
          'https://www.themealdb.com/api/json/v1/1/random.php',
        )).thenAnswer((_) async => Response(
          data: responseData,
          statusCode: 200,
          requestOptions: RequestOptions(path: ''),
        ));

        // Act
        final result = await apiService.getRandomRecipe();

        // Assert
        expect(result, isA<Recipe>());
        expect(result?.id, '52772');
      });
    });
  });
}
