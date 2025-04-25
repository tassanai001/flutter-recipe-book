import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:recipe_book/providers/refresh_provider.dart';
import 'package:recipe_book/providers/providers.dart';

// Mock ProviderRef for testing
class MockProviderRef extends Mock implements ProviderRef {}

// Create a mock provider for testing
class MockProvider extends Mock {
  // This is just a placeholder for the fallback value
  // We don't need to implement any methods
}

void main() {
  setUpAll(() {
    // Register fallback value for ProviderOrFamily
    registerFallbackValue(categoriesProvider);
  });

  group('RefreshService Tests', () {
    late MockProviderRef mockRef;
    late RefreshService refreshService;
    late List<ProviderOrFamily> invalidatedProviders;

    setUp(() {
      mockRef = MockProviderRef();
      refreshService = RefreshService(mockRef);
      invalidatedProviders = [];

      // Setup the mock to track invalidated providers
      when(() => mockRef.invalidate(any())).thenAnswer((invocation) {
        final provider = invocation.positionalArguments[0] as ProviderOrFamily;
        invalidatedProviders.add(provider);
      });
    });

    test('refreshAll should invalidate all data providers', () async {
      // Act
      await refreshService.refreshAll();
      
      // Assert
      verify(() => mockRef.invalidate(categoriesProvider)).called(1);
      verify(() => mockRef.invalidate(randomRecipeProvider)).called(1);
      verify(() => mockRef.invalidate(filteredRecipesProvider)).called(1);
      verify(() => mockRef.invalidate(favoriteIdsProvider)).called(1);
      verify(() => mockRef.invalidate(favoriteRecipesProvider)).called(1);
    });

    test('refreshHomeData should invalidate home screen providers', () async {
      // Act
      await refreshService.refreshHomeData();
      
      // Assert
      verify(() => mockRef.invalidate(categoriesProvider)).called(1);
      verify(() => mockRef.invalidate(randomRecipeProvider)).called(1);
      verify(() => mockRef.invalidate(filteredRecipesProvider)).called(1);
      verifyNever(() => mockRef.invalidate(favoriteIdsProvider));
      verifyNever(() => mockRef.invalidate(favoriteRecipesProvider));
    });

    test('refreshSearchData should invalidate search-related providers', () async {
      // Act
      await refreshService.refreshSearchData();
      
      // Assert
      verify(() => mockRef.invalidate(categoriesProvider)).called(1);
      verify(() => mockRef.invalidate(searchRecipesProvider)).called(1);
      verifyNever(() => mockRef.invalidate(favoriteIdsProvider));
      verifyNever(() => mockRef.invalidate(favoriteRecipesProvider));
    });

    test('refreshFavoritesData should invalidate favorites-related providers', () async {
      // Act
      await refreshService.refreshFavoritesData();
      
      // Assert
      verify(() => mockRef.invalidate(favoriteIdsProvider)).called(1);
      verify(() => mockRef.invalidate(favoriteRecipesProvider)).called(1);
      verifyNever(() => mockRef.invalidate(categoriesProvider));
      verifyNever(() => mockRef.invalidate(randomRecipeProvider));
    });
  });
}
