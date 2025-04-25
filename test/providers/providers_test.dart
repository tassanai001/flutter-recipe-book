import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_book/data/repositories/recipe_repository.dart';
import 'package:recipe_book/models/category.dart' as app_models;
import 'package:recipe_book/models/recipe.dart';
import 'package:recipe_book/providers/providers.dart';

// Create mock class
class MockRecipeRepository extends Mock implements RecipeRepository {}

void main() {
  group('Provider Tests', () {
    late ProviderContainer container;
    late MockRecipeRepository mockRepository;

    setUp(() {
      mockRepository = MockRecipeRepository();
      
      // Override providers for testing
      container = ProviderContainer(
        overrides: [
          recipeRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    // Helper function to create a test recipe
    Recipe createTestRecipe({String id = '52772', String category = 'Chicken'}) {
      return Recipe(
        id: id,
        name: 'Teriyaki Chicken Casserole',
        category: category,
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
    app_models.Category createTestCategory() {
      return const app_models.Category(
        id: '1',
        name: 'Beef',
        thumbnailUrl: 'https://example.com/beef.png',
        description: 'Beef is the culinary name for meat from cattle...',
      );
    }

    group('categoriesProvider', () {
      test('should fetch categories from repository', () async {
        // Arrange
        final testCategories = [createTestCategory()];
        when(() => mockRepository.getCategories())
            .thenAnswer((_) async => testCategories);

        // Act
        final result = await container.read(categoriesProvider.future);

        // Assert
        expect(result, testCategories);
        verify(() => mockRepository.getCategories()).called(1);
      });

      test('should handle error when fetching categories', () async {
        // Arrange
        when(() => mockRepository.getCategories())
            .thenThrow(Exception('Failed to fetch categories'));

        // Act & Assert
        expect(
          () => container.read(categoriesProvider.future),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('recipesByCategoryProvider', () {
      test('should fetch recipes by category from repository', () async {
        // Arrange
        final testRecipes = [createTestRecipe()];
        when(() => mockRepository.getRecipesByCategory('Chicken'))
            .thenAnswer((_) async => testRecipes);

        // Act
        final result = await container.read(recipesByCategoryProvider('Chicken').future);

        // Assert
        expect(result, testRecipes);
        verify(() => mockRepository.getRecipesByCategory('Chicken')).called(1);
      });
    });

    group('recipesByAreaProvider', () {
      test('should fetch recipes by area from repository', () async {
        // Arrange
        final testRecipes = [createTestRecipe()];
        when(() => mockRepository.getRecipesByArea('Japanese'))
            .thenAnswer((_) async => testRecipes);

        // Act
        final result = await container.read(recipesByAreaProvider('Japanese').future);

        // Assert
        expect(result, testRecipes);
        verify(() => mockRepository.getRecipesByArea('Japanese')).called(1);
      });
    });

    group('recipeDetailsProvider', () {
      test('should fetch recipe details from repository', () async {
        // Arrange
        final testRecipe = createTestRecipe();
        when(() => mockRepository.getRecipeById('52772'))
            .thenAnswer((_) async => testRecipe);

        // Act
        final result = await container.read(recipeDetailsProvider('52772').future);

        // Assert
        expect(result, testRecipe);
        verify(() => mockRepository.getRecipeById('52772')).called(1);
      });

      test('should return null when recipe is not found', () async {
        // Arrange
        when(() => mockRepository.getRecipeById('99999'))
            .thenAnswer((_) async => null);

        // Act
        final result = await container.read(recipeDetailsProvider('99999').future);

        // Assert
        expect(result, isNull);
        verify(() => mockRepository.getRecipeById('99999')).called(1);
      });
    });

    group('searchRecipesProvider', () {
      test('should return empty list for empty query', () async {
        // Act
        final result = await container.read(searchRecipesProvider('').future);

        // Assert
        expect(result, isEmpty);
        verifyNever(() => mockRepository.searchRecipes(any()));
      });

      test('should fetch search results from repository', () async {
        // Arrange
        final testRecipes = [createTestRecipe()];
        when(() => mockRepository.searchRecipes('chicken'))
            .thenAnswer((_) async => testRecipes);

        // Act
        final result = await container.read(searchRecipesProvider('chicken').future);

        // Assert
        expect(result, testRecipes);
        verify(() => mockRepository.searchRecipes('chicken')).called(1);
      });
    });

    group('randomRecipeProvider', () {
      test('should fetch random recipe from repository', () async {
        // Arrange
        final testRecipe = createTestRecipe();
        when(() => mockRepository.getRandomRecipe())
            .thenAnswer((_) async => testRecipe);

        // Act
        final result = await container.read(randomRecipeProvider.future);

        // Assert
        expect(result, testRecipe);
        verify(() => mockRepository.getRandomRecipe()).called(1);
      });
    });

    group('filteredRecipesProvider', () {
      test('should prioritize search query when available', () async {
        // Arrange
        container.read(searchQueryProvider.notifier).state = 'chicken';
        container.read(categoryFilterProvider.notifier).state = 'Beef';
        
        final searchResults = [createTestRecipe()];
        when(() => mockRepository.searchRecipes('chicken'))
            .thenAnswer((_) async => searchResults);

        // Act
        final result = await container.read(filteredRecipesProvider.future);

        // Assert
        expect(result, searchResults);
        verify(() => mockRepository.searchRecipes('chicken')).called(1);
        verifyNever(() => mockRepository.getRecipesByCategory(any()));
      });

      test('should use category filter when search query is empty', () async {
        // Arrange
        container.read(searchQueryProvider.notifier).state = '';
        container.read(categoryFilterProvider.notifier).state = 'Beef';
        
        final categoryResults = [createTestRecipe(category: 'Beef')];
        when(() => mockRepository.getRecipesByCategory('Beef'))
            .thenAnswer((_) async => categoryResults);

        // Act
        final result = await container.read(filteredRecipesProvider.future);

        // Assert
        expect(result, categoryResults);
        verify(() => mockRepository.getRecipesByCategory('Beef')).called(1);
        verifyNever(() => mockRepository.searchRecipes(any()));
      });

      test('should use area filter when search query and category filter are empty', () async {
        // Arrange
        container.read(searchQueryProvider.notifier).state = '';
        container.read(categoryFilterProvider.notifier).state = null;
        container.read(areaFilterProvider.notifier).state = 'Japanese';
        
        final areaResults = [createTestRecipe()];
        when(() => mockRepository.getRecipesByArea('Japanese'))
            .thenAnswer((_) async => areaResults);

        // Act
        final result = await container.read(filteredRecipesProvider.future);

        // Assert
        expect(result, areaResults);
        verify(() => mockRepository.getRecipesByArea('Japanese')).called(1);
      });

      test('should default to Beef category when no filters are active', () async {
        // Arrange
        container.read(searchQueryProvider.notifier).state = '';
        container.read(categoryFilterProvider.notifier).state = null;
        container.read(areaFilterProvider.notifier).state = null;
        
        final defaultResults = [createTestRecipe(category: 'Beef')];
        when(() => mockRepository.getRecipesByCategory('Beef'))
            .thenAnswer((_) async => defaultResults);

        // Act
        final result = await container.read(filteredRecipesProvider.future);

        // Assert
        expect(result, defaultResults);
        verify(() => mockRepository.getRecipesByCategory('Beef')).called(1);
      });

      test('should return empty list when default category fetch fails', () async {
        // Arrange
        container.read(searchQueryProvider.notifier).state = '';
        container.read(categoryFilterProvider.notifier).state = null;
        container.read(areaFilterProvider.notifier).state = null;
        
        when(() => mockRepository.getRecipesByCategory('Beef'))
            .thenThrow(Exception('Failed to fetch'));

        // Act
        final result = await container.read(filteredRecipesProvider.future);

        // Assert
        expect(result, isEmpty);
        verify(() => mockRepository.getRecipesByCategory('Beef')).called(1);
      });
    });

    group('favoriteIdsProvider', () {
      test('should fetch favorite IDs from repository', () async {
        // Arrange
        when(() => mockRepository.getFavoriteIds())
            .thenAnswer((_) async => ['1', '2', '3']);

        // Act
        final result = await container.read(favoriteIdsProvider.future);

        // Assert
        expect(result, ['1', '2', '3']);
        verify(() => mockRepository.getFavoriteIds()).called(1);
      });
    });

    group('favoriteRecipesProvider', () {
      test('should fetch favorite recipes from repository', () async {
        // Arrange
        final testRecipes = [
          createTestRecipe(id: '1'),
          createTestRecipe(id: '2'),
        ];
        when(() => mockRepository.getFavoriteRecipes())
            .thenAnswer((_) async => testRecipes);

        // Act
        final result = await container.read(favoriteRecipesProvider.future);

        // Assert
        expect(result, testRecipes);
        verify(() => mockRepository.getFavoriteRecipes()).called(1);
      });
    });

    group('isFavoriteProvider', () {
      test('should check if recipe is favorite using repository', () async {
        // Arrange
        when(() => mockRepository.isFavorite('52772'))
            .thenAnswer((_) async => true);

        // Act
        final result = await container.read(isFavoriteProvider('52772').future);

        // Assert
        expect(result, isTrue);
        verify(() => mockRepository.isFavorite('52772')).called(1);
      });
    });
  });
}
