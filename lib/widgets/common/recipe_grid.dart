import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_book/models/recipe.dart';
import 'package:recipe_book/utils/constants.dart';
import 'package:recipe_book/widgets/common/recipe_card.dart';

/// A grid widget for displaying a list of recipes
class RecipeGrid extends ConsumerWidget {
  final List<Recipe> recipes;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final Function(Recipe)? onFavoriteToggle;
  final Function(Recipe)? onRecipeTap;

  const RecipeGrid({
    super.key,
    required this.recipes,
    this.isLoading = false,
    this.errorMessage,
    this.onRetry,
    this.onFavoriteToggle,
    this.onRecipeTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Show loading state
    if (isLoading) {
      return _buildLoadingGrid();
    }

    // Show error state
    if (errorMessage != null) {
      return _buildErrorState(context);
    }

    // Show empty state
    if (recipes.isEmpty) {
      return _buildEmptyState(context);
    }

    // Show recipes grid
    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: AppConstants.defaultPadding,
        mainAxisSpacing: AppConstants.defaultPadding,
      ),
      itemCount: recipes.length,
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        
        return RecipeCard(
          recipe: recipe,
          onFavoriteToggle: onFavoriteToggle != null 
              ? () => onFavoriteToggle!(recipe)
              : null,
          onTap: onRecipeTap != null 
              ? () => onRecipeTap!(recipe)
              : null,
        );
      },
    );
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: AppConstants.defaultPadding,
        mainAxisSpacing: AppConstants.defaultPadding,
      ),
      itemCount: 6, // Show 6 placeholder items
      itemBuilder: (context, index) {
        return const RecipeCardPlaceholder();
      },
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            errorMessage ?? AppConstants.generalErrorMessage,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: AppConstants.defaultPadding),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: AppConstants.defaultPadding),
          Text(
            AppConstants.noResultsMessage,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
