import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_book/providers/providers.dart';
import 'package:recipe_book/screens/detail/recipe_detail_screen.dart';
import 'package:recipe_book/utils/constants.dart';
import 'package:recipe_book/widgets/common/recipe_grid.dart';

/// Screen for displaying user's favorite recipes
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the favorite recipes provider to get all favorites
    final favoritesAsync = ref.watch(favoriteRecipesProvider);

    return Column(
      children: [
        // Action buttons for managing favorites
        Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Sort button (placeholder for future functionality)
              IconButton(
                icon: const Icon(Icons.sort),
                tooltip: 'Sort favorites',
                onPressed: () {
                  // Future functionality: Sort favorites by name, date added, etc.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Sorting will be implemented in a future update'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              // Clear all favorites button
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Clear all favorites',
                onPressed: () => _showClearFavoritesDialog(context, ref),
              ),
            ],
          ),
        ),

        // Favorites list
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              // Refresh favorites
              ref.invalidate(favoriteRecipesProvider);
            },
            child: favoritesAsync.when(
              data: (favorites) {
                if (favorites.isEmpty) {
                  return _buildEmptyFavoritesState(context);
                }
                
                return RecipeGrid(
                  recipes: favorites,
                  onFavoriteToggle: (recipe) async {
                    // Remove from favorites when toggled in favorites screen
                    final repository = ref.read(recipeRepositoryProvider);
                    await repository.removeFromFavorites(recipe.id);
                    ref.invalidate(favoriteRecipesProvider);
                    ref.invalidate(favoriteIdsProvider);
                    
                    // Show confirmation
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${recipe.name} removed from favorites'),
                          action: SnackBarAction(
                            label: 'Undo',
                            onPressed: () async {
                              // Add back to favorites
                              await repository.addToFavorites(recipe);
                              ref.invalidate(favoriteRecipesProvider);
                              ref.invalidate(favoriteIdsProvider);
                            },
                          ),
                        ),
                      );
                    }
                  },
                  onRecipeTap: (recipe) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailScreen(recipe: recipe),
                      ),
                    );
                  },
                );
              },
              loading: () => const RecipeGrid(
                recipes: [],
                isLoading: true,
              ),
              error: (error, stackTrace) => RecipeGrid(
                recipes: [],
                errorMessage: error.toString(),
                onRetry: () => ref.invalidate(favoriteRecipesProvider),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyFavoritesState(BuildContext context) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.largePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Icon(
                Icons.favorite_border,
                size: 80,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              Text(
                'No Favorites Yet',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.smallPadding),
              Text(
                AppConstants.emptyFavoritesMessage,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
              ),
              const SizedBox(height: AppConstants.largePadding),
              ElevatedButton.icon(
                onPressed: () {
                  // Find the parent Scaffold and use its state to navigate
                  final scaffoldState = ScaffoldMessenger.of(context);
                  scaffoldState.showSnackBar(
                    const SnackBar(
                      content: Text('Tap the Home tab to discover recipes'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.home),
                label: const Text('Discover Recipes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClearFavoritesDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Favorites'),
        content: const Text('Are you sure you want to remove all favorites? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              // Clear all favorites
              final localStorage = ref.read(favoritesLocalStorageProvider);
              await localStorage.clearFavorites();
              
              // Refresh providers
              ref.invalidate(favoriteRecipesProvider);
              ref.invalidate(favoriteIdsProvider);
              
              // Close dialog and show confirmation
              if (context.mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('All favorites have been cleared'),
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }
}
