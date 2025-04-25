import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_book/providers/providers.dart';

/// A provider that handles refreshing all data in the app
/// This is used by the pull-to-refresh functionality
final refreshProvider = Provider<RefreshService>((ref) {
  return RefreshService(ref);
});

/// Service class for handling refresh operations
class RefreshService {
  final ProviderRef _ref;

  RefreshService(this._ref);

  /// Refreshes all data in the app
  /// Returns a Future that completes when all data has been refreshed
  Future<void> refreshAll() async {
    // Invalidate all data providers to force a refresh
    _ref.invalidate(categoriesProvider);
    _ref.invalidate(randomRecipeProvider);
    _ref.invalidate(filteredRecipesProvider);
    _ref.invalidate(favoriteIdsProvider);
    _ref.invalidate(favoriteRecipesProvider);
  }

  /// Refreshes only home screen data
  Future<void> refreshHomeData() async {
    _ref.invalidate(categoriesProvider);
    _ref.invalidate(randomRecipeProvider);
    _ref.invalidate(filteredRecipesProvider);
  }

  /// Refreshes only search data
  Future<void> refreshSearchData() async {
    _ref.invalidate(categoriesProvider);
    _ref.invalidate(searchRecipesProvider);
  }

  /// Refreshes only favorites data
  Future<void> refreshFavoritesData() async {
    _ref.invalidate(favoriteIdsProvider);
    _ref.invalidate(favoriteRecipesProvider);
  }
}
