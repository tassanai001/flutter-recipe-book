import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_book/utils/constants.dart';

/// Screen for displaying user's favorite recipes
class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        // Empty state
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                ),
                const SizedBox(height: AppConstants.defaultPadding),
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
                    // Navigate back to home screen
                  },
                  icon: const Icon(Icons.search),
                  label: const Text('Discover Recipes'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
