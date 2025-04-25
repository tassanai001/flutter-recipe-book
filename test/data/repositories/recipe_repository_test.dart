import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_book/data/api/recipe_api_service.dart';
import 'package:recipe_book/data/local/favorites_local_storage.dart';
import 'package:recipe_book/data/repositories/recipe_repository.dart';
import 'package:recipe_book/models/category.dart';
import 'package:recipe_book/models/recipe.dart';

// Create mock classes
class MockRecipeApiService extends Mock implements RecipeApiService {}
class MockFavoritesLocalStorage extends Mock implements FavoritesLocalStorage {}

void main() {
  group('RecipeRepository Tests', () {
    late RecipeRepository repository;
    late MockRecipeApiService mockApiService;
    late MockFavoritesLocalStorage mockLocalStorage;

    setUp(() {
      mockApiService = MockRecipeApiService();
      mockLocalStorage = MockFavoritesLocalStorage();
      repository = RecipeRepository(
        apiService: mockApiService,
        localStorage: mockLocalStorage,
      );
    });

    // Helper function to create a test recipe
    Recipe createTestRecipe({String id = '52772'}) {
      return Recipe(
        id: id,
        name: 'Teriyaki Chicken Casserole',
        category: 'Chicken',
        area: 'Japanese',
        instructions: 'Test instructions',
        thumbnailUrl: 'https://example.com/image.jpg',
        youtubeUrl: 'https://youtube.com/watch?v=123',
        originalData: {'idMeal': id, 'strMeal': 'Teriyaki Chicken Casserole'},
        ingredients: ['Chicken', 'Sauce'],
        measurements: ['1 pound', '1/2 cup'],
        ingredientsWithMeasurements: {'Chicken': '1 pound', 'Sauce': '1/2 cup'},
        tags: ['Meat', 'Casserole'],
      );
    }

    // Helper function to create a test category
    Category createTestCategory() {
      return const Category(
        id: '1',
        name: 'Beef',
        thumbnailUrl: 'https://example.com/beef.png',
        description: 'Beef is the culinary name for meat from cattle...',
      );
    }

    group('getRecipesByCategory', () {
      test('should return recipes from API service', () async {
        // Arrange
        final testRecipes = [createTestRecipe()];
        when(() => mockApiService.getRecipesByCategory('Chicken'))
            .thenAnswer((_) async => testRecipes);

        // Act
        final result = await repository.getRecipesByCategory('Chicken');

        // Assert
        expect(result, testRecipes);
        verify(() => mockApiService.getRecipesByCategory('Chicken')).called(1);
      });
    });

    group('getCategories', () {
      test('should return categories from API service', () async {
        // Arrange
        final testCategories = [createTestCategory()];
        when(() => mockApiService.getCategories())
            .thenAnswer((_) async => testCategories);

        // Act
        final result = await repository.getCategories();

        // Assert
        expect(result, testCategories);
        verify(() => mockApiService.getCategories()).called(1);
      });
    });

    group('getRecipeById', () {
      test('should return recipe from API service', () async {
        // Arrange
        final testRecipe = createTestRecipe();
        when(() => mockApiService.getRecipeById('52772'))
            .thenAnswer((_) async => testRecipe);

        // Act
        final result = await repository.getRecipeById('52772');

        // Assert
        expect(result, testRecipe);
        verify(() => mockApiService.getRecipeById('52772')).called(1);
      });
    });

    group('searchRecipes', () {
      test('should return search results from API service', () async {
        // Arrange
        final testRecipes = [createTestRecipe()];
        when(() => mockApiService.searchRecipes('chicken'))
            .thenAnswer((_) async => testRecipes);

        // Act
        final result = await repository.searchRecipes('chicken');

        // Assert
        expect(result, testRecipes);
        verify(() => mockApiService.searchRecipes('chicken')).called(1);
      });
    });

    group('getRecipesByArea', () {
      test('should return recipes from API service', () async {
        // Arrange
        final testRecipes = [createTestRecipe()];
        when(() => mockApiService.getRecipesByArea('Japanese'))
            .thenAnswer((_) async => testRecipes);

        // Act
        final result = await repository.getRecipesByArea('Japanese');

        // Assert
        expect(result, testRecipes);
        verify(() => mockApiService.getRecipesByArea('Japanese')).called(1);
      });
    });

    group('getRandomRecipe', () {
      test('should return random recipe from API service', () async {
        // Arrange
        final testRecipe = createTestRecipe();
        when(() => mockApiService.getRandomRecipe())
            .thenAnswer((_) async => testRecipe);

        // Act
        final result = await repository.getRandomRecipe();

        // Assert
        expect(result, testRecipe);
        verify(() => mockApiService.getRandomRecipe()).called(1);
      });
    });

    group('getFavoriteIds', () {
      test('should return favorite IDs from local storage', () async {
        // Arrange
        when(() => mockLocalStorage.getFavoriteIds())
            .thenAnswer((_) async => ['1', '2', '3']);

        // Act
        final result = await repository.getFavoriteIds();

        // Assert
        expect(result, ['1', '2', '3']);
        verify(() => mockLocalStorage.getFavoriteIds()).called(1);
      });
    });

    group('isFavorite', () {
      test('should check if recipe is favorite using local storage', () async {
        // Arrange
        when(() => mockLocalStorage.isFavorite('52772'))
            .thenAnswer((_) async => true);

        // Act
        final result = await repository.isFavorite('52772');

        // Assert
        expect(result, isTrue);
        verify(() => mockLocalStorage.isFavorite('52772')).called(1);
      });
    });

    group('addToFavorites', () {
      test('should add recipe to favorites using local storage', () async {
        // Arrange
        final testRecipe = createTestRecipe();
        when(() => mockLocalStorage.addToFavorites(testRecipe))
            .thenAnswer((_) async => {});

        // Act
        await repository.addToFavorites(testRecipe);

        // Assert
        verify(() => mockLocalStorage.addToFavorites(testRecipe)).called(1);
      });
    });

    group('removeFromFavorites', () {
      test('should remove recipe from favorites using local storage', () async {
        // Arrange
        when(() => mockLocalStorage.removeFromFavorites('52772'))
            .thenAnswer((_) async => {});

        // Act
        await repository.removeFromFavorites('52772');

        // Assert
        verify(() => mockLocalStorage.removeFromFavorites('52772')).called(1);
      });
    });

    group('getFavoriteRecipes', () {
      test('should return favorite recipes by fetching details for each ID', () async {
        // Arrange
        when(() => mockLocalStorage.getFavoriteIds())
            .thenAnswer((_) async => ['1', '2']);
        
        final recipe1 = createTestRecipe(id: '1');
        final recipe2 = createTestRecipe(id: '2');
        
        when(() => mockApiService.getRecipeById('1'))
            .thenAnswer((_) async => recipe1);
        when(() => mockApiService.getRecipeById('2'))
            .thenAnswer((_) async => recipe2);

        // Act
        final result = await repository.getFavoriteRecipes();

        // Assert
        expect(result.length, 2);
        expect(result[0].id, '1');
        expect(result[1].id, '2');
        verify(() => mockLocalStorage.getFavoriteIds()).called(1);
        verify(() => mockApiService.getRecipeById('1')).called(1);
        verify(() => mockApiService.getRecipeById('2')).called(1);
      });

      test('should fetch from local storage if API call fails', () async {
        // Arrange
        when(() => mockLocalStorage.getFavoriteIds())
            .thenAnswer((_) async => ['1', '2']);
        
        final recipe1 = createTestRecipe(id: '1');
        
        when(() => mockApiService.getRecipeById('1'))
            .thenAnswer((_) async => recipe1);
        when(() => mockApiService.getRecipeById('2'))
            .thenThrow(Exception('API error'));
        
        final localRecipe2 = createTestRecipe(id: '2');
        when(() => mockLocalStorage.getRecipeById('2'))
            .thenAnswer((_) async => localRecipe2);

        // Act
        final result = await repository.getFavoriteRecipes();

        // Assert
        expect(result.length, 2);
        expect(result[0].id, '1');
        expect(result[1].id, '2');
        verify(() => mockLocalStorage.getFavoriteIds()).called(1);
        verify(() => mockApiService.getRecipeById('1')).called(1);
        verify(() => mockApiService.getRecipeById('2')).called(1);
        verify(() => mockLocalStorage.getRecipeById('2')).called(1);
      });

      test('should skip recipes that are not found in either API or local storage', () async {
        // Arrange
        when(() => mockLocalStorage.getFavoriteIds())
            .thenAnswer((_) async => ['1', '2']);
        
        final recipe1 = createTestRecipe(id: '1');
        
        when(() => mockApiService.getRecipeById('1'))
            .thenAnswer((_) async => recipe1);
        when(() => mockApiService.getRecipeById('2'))
            .thenThrow(Exception('API error'));
        
        when(() => mockLocalStorage.getRecipeById('2'))
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.getFavoriteRecipes();

        // Assert
        expect(result.length, 1);
        expect(result[0].id, '1');
        verify(() => mockLocalStorage.getFavoriteIds()).called(1);
        verify(() => mockApiService.getRecipeById('1')).called(1);
        verify(() => mockApiService.getRecipeById('2')).called(1);
        verify(() => mockLocalStorage.getRecipeById('2')).called(1);
      });
    });
  });
}
