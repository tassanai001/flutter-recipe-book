import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_book/models/recipe.dart';
import 'package:recipe_book/providers/providers.dart';
import 'package:recipe_book/utils/constants.dart';
import 'package:recipe_book/widgets/common/recipe_card.dart';

/// A grid widget for displaying a paginated list of recipes with infinite scrolling
class PaginatedRecipeGrid extends ConsumerStatefulWidget {
  final Function(Recipe)? onFavoriteToggle;
  final Function(Recipe)? onRecipeTap;
  final String? category;
  final String? area;
  final String? searchQuery;
  
  const PaginatedRecipeGrid({
    super.key,
    this.onFavoriteToggle,
    this.onRecipeTap,
    this.category,
    this.area,
    this.searchQuery,
  });

  @override
  ConsumerState<PaginatedRecipeGrid> createState() => _PaginatedRecipeGridState();
}

class _PaginatedRecipeGridState extends ConsumerState<PaginatedRecipeGrid> {
  final ScrollController _scrollController = ScrollController();
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMore();
    }
  }

  Future<void> _loadMore() async {
    final notifier = ref.read(paginatedRecipesProvider.notifier);
    
    if (widget.category != null) {
      await notifier.loadMoreRecipesByCategory();
    } else if (widget.area != null) {
      await notifier.loadMoreRecipesByArea();
    } else if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      await notifier.loadMoreSearchResults();
    }
  }

  Future<void> _loadInitialData() async {
    final notifier = ref.read(paginatedRecipesProvider.notifier);
    
    if (widget.category != null) {
      await notifier.loadRecipesByCategory(widget.category!);
    } else if (widget.area != null) {
      await notifier.loadRecipesByArea(widget.area!);
    } else if (widget.searchQuery != null && widget.searchQuery!.isNotEmpty) {
      await notifier.searchRecipes(widget.searchQuery!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final paginatedRecipesState = ref.watch(paginatedRecipesProvider);
    final recipes = paginatedRecipesState.items;
    final pagination = paginatedRecipesState.pagination;
    
    // Load initial data if needed
    if (!_isInitialized) {
      _isInitialized = true;
      Future.microtask(() => _loadInitialData());
    }
    
    // If there are no recipes and we're still loading, show loading state
    if (recipes.isEmpty && pagination.isLoading) {
      return _buildLoadingGrid();
    }
    
    // If there are no recipes and we're not loading, show empty state
    if (recipes.isEmpty && !pagination.isLoading) {
      return _buildEmptyState(context);
    }
    
    return Stack(
      children: [
        // Recipe grid
        GridView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.7,
            crossAxisSpacing: AppConstants.defaultPadding,
            mainAxisSpacing: AppConstants.defaultPadding,
          ),
          itemCount: recipes.length + (pagination.hasMore ? 1 : 0),
          itemBuilder: (context, index) {
            // If we're at the end and there are more items, show a loading indicator
            if (index == recipes.length) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppConstants.defaultPadding),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            final recipe = recipes[index];
            
            return RecipeCard(
              recipe: recipe,
              onFavoriteToggle: widget.onFavoriteToggle != null 
                  ? () => widget.onFavoriteToggle!(recipe)
                  : null,
              onTap: widget.onRecipeTap != null 
                  ? () => widget.onRecipeTap!(recipe)
                  : null,
            );
          },
        ),
        
        // Loading indicator overlay
        if (pagination.isLoading && recipes.isNotEmpty)
          const Positioned(
            bottom: 16,
            right: 16,
            child: CircularProgressIndicator(),
          ),
      ],
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
          const SizedBox(height: AppConstants.defaultPadding),
          ElevatedButton.icon(
            onPressed: _loadInitialData,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
