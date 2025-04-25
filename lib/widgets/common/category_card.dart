import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_book/models/category.dart' as app_models;
import 'package:recipe_book/providers/providers.dart';
import 'package:recipe_book/utils/constants.dart';
import 'package:recipe_book/utils/image_utils.dart';
import 'package:shimmer/shimmer.dart';

/// A card widget for displaying a recipe category
class CategoryCard extends ConsumerWidget {
  final app_models.Category category;
  final bool isSelected;

  const CategoryCard({
    super.key,
    required this.category,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        // Toggle category selection
        final currentCategory = ref.read(categoryFilterProvider);
        if (currentCategory == category.name) {
          // If already selected, clear filter
          ref.read(categoryFilterProvider.notifier).state = null;
        } else {
          // Otherwise, set this category as filter
          ref.read(categoryFilterProvider.notifier).state = category.name;
        }
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: AppConstants.smallPadding),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Category image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppConstants.defaultBorderRadius),
              ),
              child: OptimizedImage(
                imageUrl: category.thumbnailUrl,
                height: 70,
                width: 100,
                useShimmerEffect: true,
              ),
            ),
            
            // Category name
            Padding(
              padding: const EdgeInsets.all(AppConstants.smallPadding),
              child: Text(
                category.name,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A placeholder for the CategoryCard when loading
class CategoryCardPlaceholder extends StatelessWidget {
  const CategoryCardPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: AppConstants.smallPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image placeholder
            Container(
              height: 70,
              width: 100,
              color: Colors.white,
            ),
            
            // Text placeholder
            Padding(
              padding: const EdgeInsets.all(AppConstants.smallPadding),
              child: Container(
                height: 12,
                width: 80,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
