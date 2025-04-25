import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_book/models/recipe.dart';
import 'package:recipe_book/providers/providers.dart';
import 'package:recipe_book/utils/constants.dart';
import 'package:recipe_book/utils/image_utils.dart';
import 'package:recipe_book/utils/url_utils.dart';

/// Screen for displaying detailed information about a recipe
class RecipeDetailScreen extends ConsumerWidget {
  final Recipe recipe;

  const RecipeDetailScreen({
    super.key,
    required this.recipe,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch favorite ids to determine if this recipe is a favorite
    final favoriteIdsAsync = ref.watch(favoriteIdsProvider);
    final isFavorite = favoriteIdsAsync.when(
      data: (ids) => ids.contains(recipe.id),
      loading: () => false,
      error: (_, __) => false,
    );
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          _buildRecipeContent(context),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: isFavorite ? Colors.red : null,
        onPressed: () async {
          // Toggle favorite status
          final repository = ref.read(recipeRepositoryProvider);
          if (isFavorite) {
            await repository.removeFromFavorites(recipe.id);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${recipe.name} removed from favorites'),
                  action: SnackBarAction(
                    label: 'Undo',
                    onPressed: () async {
                      await repository.addToFavorites(recipe);
                      ref.invalidate(favoriteIdsProvider);
                      ref.invalidate(favoriteRecipesProvider);
                    },
                  ),
                ),
              );
            }
          } else {
            await repository.addToFavorites(recipe);
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${recipe.name} added to favorites'),
                ),
              );
            }
          }
          ref.invalidate(favoriteIdsProvider);
          ref.invalidate(favoriteRecipesProvider);
        },
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: isFavorite ? Colors.white : null,
        ),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          recipe.name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                blurRadius: 4,
                color: Colors.black54,
                offset: Offset(0, 2),
              ),
            ],
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Recipe image
            OptimizedImage(
              imageUrl: recipe.thumbnailUrl,
              fit: BoxFit.cover,
              useShimmerEffect: false,
            ),
            // Gradient overlay for better text visibility
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black54,
                  ],
                  stops: [0.7, 1.0],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecipeContent(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // Category and area
          Wrap(
            spacing: AppConstants.smallPadding,
            children: [
              if (recipe.category.isNotEmpty)
                Chip(
                  label: Text(recipe.category),
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                ),
              if (recipe.area.isNotEmpty)
                Chip(
                  label: Text(recipe.area),
                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                ),
              if (recipe.tags.isNotEmpty)
                ...recipe.tags.map((tag) => Chip(
                      label: Text(tag.trim()),
                      backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
                    )),
            ],
          ),
          
          const SizedBox(height: AppConstants.defaultPadding),
          
          // Ingredients section
          Text(
            AppConstants.ingredientsTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          _buildIngredientsList(),
          
          const SizedBox(height: AppConstants.defaultPadding),
          
          // Instructions section
          Text(
            AppConstants.instructionsTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          _buildInstructions(context),
          
          if (recipe.youtubeUrl != null) ...[
            const SizedBox(height: AppConstants.defaultPadding),
            Text(
              'Video Tutorial',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppConstants.smallPadding),
            OutlinedButton.icon(
              icon: const Icon(Icons.play_circle_outline),
              label: const Text('Watch on YouTube'),
              onPressed: () {
                UrlUtils.launchYouTubeVideo(
                  recipe.youtubeUrl,
                  context: context,
                );
              },
            ),
          ],
          
          const SizedBox(height: 100), // Extra space at the bottom
        ]),
      ),
    );
  }

  Widget _buildIngredientsList() {
    if (recipe.ingredients.isEmpty) {
      return const Text('No ingredients available.');
    }
    
    return Column(
      children: List.generate(
        recipe.ingredients.length,
        (index) => ListTile(
          leading: const Icon(Icons.check_circle_outline),
          title: Text(recipe.ingredients[index]),
          subtitle: recipe.measurements[index].isNotEmpty 
              ? Text(recipe.measurements[index]) 
              : null,
          dense: true,
        ),
      ),
    );
  }

  Widget _buildInstructions(BuildContext context) {
    if (recipe.instructions.isEmpty) {
      return const Text('No instructions available.');
    }
    
    // Split instructions by newlines or periods followed by a space
    final steps = recipe.instructions
        .split(RegExp(r'\n|\. '))
        .where((step) => step.trim().isNotEmpty)
        .map((step) => step.endsWith('.') ? step : '$step.')
        .toList();
    
    if (steps.length <= 1) {
      // If there's only one step or no clear delineation between steps,
      // just show the whole instructions text
      return Text(recipe.instructions);
    }
    
    // Otherwise, show numbered steps
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(
        steps.length,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.smallPadding),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Expanded(
                child: Text(steps[index].trim()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
