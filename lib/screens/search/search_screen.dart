import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_book/models/category.dart' as app_models;
import 'package:recipe_book/providers/providers.dart';
import 'package:recipe_book/providers/refresh_provider.dart';
import 'package:recipe_book/screens/detail/recipe_detail_screen.dart';
import 'package:recipe_book/utils/constants.dart';
import 'package:recipe_book/utils/debouncer.dart';
import 'package:recipe_book/widgets/common/paginated_recipe_grid.dart';
import 'package:recipe_book/widgets/common/pull_to_refresh.dart';

/// Screen for searching recipes
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Debouncer _debouncer = Debouncer(
    delay: AppConstants.searchDebounceTime,
  );

  @override
  void initState() {
    super.initState();
    // Initialize search controller with current search query if any
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentQuery = ref.read(searchQueryProvider);
      if (currentQuery.isNotEmpty) {
        _searchController.text = currentQuery;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch the search query to get current search term
    final searchQuery = ref.watch(searchQueryProvider);
    
    // Watch the category filter to highlight selected category
    final selectedCategory = ref.watch(categoryFilterProvider);
    
    // Watch categories for filter chips
    final categoriesAsync = ref.watch(categoriesProvider);
    
    // Get refresh service
    final refreshService = ref.watch(refreshProvider);

    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search recipes...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _clearSearch,
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.defaultBorderRadius,
                ),
              ),
            ),
            onChanged: _onSearchChanged,
            textInputAction: TextInputAction.search,
            onSubmitted: (value) {
              // Immediately update search when user presses enter
              ref.read(searchQueryProvider.notifier).state = value;
            },
          ),
        ),

        // Filter chips
        _buildFilterChips(categoriesAsync, selectedCategory),

        // Search results
        Expanded(
          child: PullToRefreshWrapper(
            onRefresh: () async {
              await refreshService.refreshSearchData();
              // Also refresh the paginated data
              await ref.read(paginatedRecipesProvider.notifier).refresh();
            },
            isEmpty: searchQuery.isEmpty && selectedCategory == null,
            emptyState: searchQuery.isEmpty && selectedCategory == null
                ? _buildEmptySearchState()
                : null,
            child: searchQuery.isEmpty && selectedCategory == null
                ? _buildEmptySearchState()
                : PaginatedRecipeGrid(
                    searchQuery: searchQuery.isNotEmpty ? searchQuery : null,
                    category: selectedCategory,
                    onRecipeTap: (recipe) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecipeDetailScreen(recipe: recipe),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }

  void _onSearchChanged(String query) {
    _debouncer.run(() {
      // Update search query provider after debounce
      ref.read(searchQueryProvider.notifier).state = query;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(searchQueryProvider.notifier).state = '';
    ref.read(categoryFilterProvider.notifier).state = null;
  }

  Widget _buildFilterChips(
    AsyncValue<List<app_models.Category>> categoriesAsync,
    String? selectedCategory,
  ) {
    return SizedBox(
      height: 50,
      child: categoriesAsync.when(
        data: (categories) {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.defaultPadding,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = category.name == selectedCategory;
              
              return Padding(
                padding: const EdgeInsets.only(right: AppConstants.smallPadding),
                child: FilterChip(
                  label: Text(category.name),
                  selected: isSelected,
                  onSelected: (selected) {
                    // Toggle category filter
                    if (selected) {
                      ref.read(categoryFilterProvider.notifier).state = category.name;
                    } else {
                      ref.read(categoryFilterProvider.notifier).state = null;
                    }
                  },
                ),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (_, __) => Center(
          child: TextButton.icon(
            onPressed: () => ref.invalidate(categoriesProvider),
            icon: const Icon(Icons.refresh),
            label: const Text('Reload Categories'),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptySearchState() {
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
                Icons.search,
                size: 80,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              Text(
                'Search for recipes',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.smallPadding),
              Text(
                'Enter a recipe name, ingredient, or select a category to find delicious recipes',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
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
                Icons.search_off,
                size: 80,
                color: Theme.of(context).colorScheme.error.withOpacity(0.5),
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              Text(
                'No recipes found',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.smallPadding),
              Text(
                'Try a different search term or category filter',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppConstants.defaultPadding),
              ElevatedButton.icon(
                onPressed: _clearSearch,
                icon: const Icon(Icons.clear),
                label: const Text('Clear Search'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
