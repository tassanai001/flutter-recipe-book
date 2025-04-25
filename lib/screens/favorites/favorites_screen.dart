import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_book/providers/providers.dart';
import 'package:recipe_book/providers/refresh_provider.dart';
import 'package:recipe_book/screens/detail/recipe_detail_screen.dart';
import 'package:recipe_book/utils/constants.dart';
import 'package:recipe_book/widgets/common/empty_state.dart';
import 'package:recipe_book/widgets/common/pull_to_refresh.dart';
import 'package:recipe_book/widgets/common/recipe_grid.dart';

/// Screen for displaying user's favorite recipes
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the favorite recipes provider to get all favorites
    final favoritesAsync = ref.watch(favoriteRecipesProvider);
    // Get refresh service
    final refreshService = ref.watch(refreshProvider);

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
          child: PullToRefreshWrapper(
            onRefresh: () => refreshService.refreshFavoritesData(),
            isEmpty: favoritesAsync.maybeWhen(
              data: (favorites) => favorites.isEmpty,
              orElse: () => false,
            ),
            emptyState: EmptyState(
              icon: Icons.favorite_border,
              title: 'No Favorites Yet',
              message: AppConstants.emptyFavoritesMessage,
              actionButton: ElevatedButton.icon(
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
            ),
            child: favoritesAsync.when(
              data: (favorites) {
                if (favorites.isEmpty) {
                  return const SizedBox.shrink(); // Empty state is handled by PullToRefreshWrapper
                }
                
                return RecipeGrid(
                  recipes: favorites,
                  onFavoriteToggle: (recipe) async {
                    // Remove from favorites when toggled in favorites screen
                    final repository = ref.read(recipeRepositoryProvider);
                    await repository.removeFromFavorites(recipe.id);
                    refreshService.refreshFavoritesData();
                    
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
                              refreshService.refreshFavoritesData();
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
              error: (error, stackTrace) => ErrorState(
                message: error.toString(),
                onRetry: () => refreshService.refreshFavoritesData(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showClearFavoritesDialog(BuildContext context, WidgetRef ref) {
    final refreshService = ref.read(refreshProvider);
    
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
              refreshService.refreshFavoritesData();
              
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
