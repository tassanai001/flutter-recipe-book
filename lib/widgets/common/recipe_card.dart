import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_book/models/recipe.dart';
import 'package:recipe_book/utils/constants.dart';
import 'package:shimmer/shimmer.dart';

/// A card widget for displaying a recipe in a grid
class RecipeCard extends ConsumerWidget {
  final Recipe recipe;

  const RecipeCard({
    super.key,
    required this.recipe,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      elevation: AppConstants.cardElevation,
      child: InkWell(
        onTap: () {
          // Navigate to recipe detail screen
          // This will be implemented later
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => RecipeDetailScreen(recipeId: recipe.id),
          //   ),
          // );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe image
            AspectRatio(
              aspectRatio: 1.0,
              child: CachedNetworkImage(
                imageUrl: recipe.thumbnailUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    color: Colors.white,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(
                    Icons.broken_image,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
            
            // Recipe info
            Padding(
              padding: const EdgeInsets.all(AppConstants.smallPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Recipe name
                  Text(
                    recipe.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Recipe category
                  Text(
                    recipe.category,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  
                  const SizedBox(height: 4),
                  
                  // Favorite button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Area/cuisine
                      Text(
                        recipe.area,
                        style: Theme.of(context).textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      // Favorite icon
                      IconButton(
                        icon: const Icon(Icons.favorite_border),
                        onPressed: () {
                          // Toggle favorite status
                          // This will be implemented later
                          // ref.read(favoritesProvider.notifier).addToFavorites(recipe);
                        },
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A placeholder for the RecipeCard when loading
class RecipeCardPlaceholder extends StatelessWidget {
  const RecipeCardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      elevation: AppConstants.cardElevation,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image placeholder
            AspectRatio(
              aspectRatio: 1.0,
              child: Container(
                color: Colors.white,
              ),
            ),
            
            // Text placeholders
            Padding(
              padding: const EdgeInsets.all(AppConstants.smallPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title placeholder
                  Container(
                    width: double.infinity,
                    height: 16,
                    color: Colors.white,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Subtitle placeholder
                  Container(
                    width: 100,
                    height: 12,
                    color: Colors.white,
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Bottom row placeholder
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 60,
                        height: 12,
                        color: Colors.white,
                      ),
                      Container(
                        width: 20,
                        height: 20,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
