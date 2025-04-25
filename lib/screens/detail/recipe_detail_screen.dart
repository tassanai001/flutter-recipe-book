import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_book/utils/constants.dart';

/// Screen for displaying detailed information about a recipe
class RecipeDetailScreen extends ConsumerWidget {
  final String recipeId;

  const RecipeDetailScreen({
    super.key,
    required this.recipeId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This will be implemented with actual provider later
    // final recipeAsync = ref.watch(recipeDetailsProvider(recipeId));
    
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          _buildPlaceholderContent(context),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Toggle favorite status
          // This will be implemented later
        },
        child: const Icon(Icons.favorite_border),
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 250,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        title: const Text(
          'Recipe Name',
          style: TextStyle(
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
            // Placeholder image
            Container(
              color: Colors.grey[300],
              child: const Icon(
                Icons.image,
                size: 64,
                color: Colors.grey,
              ),
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

  Widget _buildPlaceholderContent(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          // Category and area
          Row(
            children: [
              Chip(
                label: const Text('Category'),
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
              const SizedBox(width: AppConstants.smallPadding),
              Chip(
                label: const Text('Area'),
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              ),
            ],
          ),
          
          const SizedBox(height: AppConstants.defaultPadding),
          
          // Ingredients section
          Text(
            AppConstants.ingredientsTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          _buildIngredientsPlaceholder(),
          
          const SizedBox(height: AppConstants.defaultPadding),
          
          // Instructions section
          Text(
            AppConstants.instructionsTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: AppConstants.smallPadding),
          const Text(
            'Instructions will appear here when a recipe is loaded.',
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
          
          const SizedBox(height: 100), // Extra space at the bottom
        ]),
      ),
    );
  }

  Widget _buildIngredientsPlaceholder() {
    return Column(
      children: List.generate(
        5,
        (index) => ListTile(
          leading: const Icon(Icons.check_circle_outline),
          title: Text('Ingredient ${index + 1}'),
          subtitle: Text('Measurement ${index + 1}'),
          dense: true,
        ),
      ),
    );
  }
}
