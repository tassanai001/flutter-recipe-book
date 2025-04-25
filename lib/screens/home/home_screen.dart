import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_book/providers/providers.dart';
import 'package:recipe_book/providers/refresh_provider.dart';
import 'package:recipe_book/screens/detail/recipe_detail_screen.dart';
import 'package:recipe_book/screens/favorites/favorites_screen.dart';
import 'package:recipe_book/screens/search/search_screen.dart';
import 'package:recipe_book/utils/constants.dart';
import 'package:recipe_book/widgets/common/category_card.dart';
import 'package:recipe_book/widgets/common/empty_state.dart';
import 'package:recipe_book/widgets/common/pull_to_refresh.dart';
import 'package:recipe_book/widgets/common/recipe_grid.dart';

/// The main home screen of the app showing recipe categories and featured recipes
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    _HomeContent(),
    SearchScreen(),
    FavoritesScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return AppConstants.homeScreenTitle;
      case 1:
        return AppConstants.searchScreenTitle;
      case 2:
        return AppConstants.favoritesScreenTitle;
      default:
        return AppConstants.appName;
    }
  }

  @override
  Widget build(BuildContext context) {
    final refreshService = ref.watch(refreshProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Refresh the current screen based on which tab is active
              if (_selectedIndex == 0) {
                // Refresh home screen data
                refreshService.refreshHomeData();
              } else if (_selectedIndex == 1) {
                // Refresh search screen data
                refreshService.refreshSearchData();
              } else if (_selectedIndex == 2) {
                // Refresh favorites
                refreshService.refreshFavoritesData();
              }
            },
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }
}

/// The content of the home tab
class _HomeContent extends ConsumerWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the filtered recipes provider to get recipes based on current filters
    final filteredRecipesAsync = ref.watch(filteredRecipesProvider);
    final refreshService = ref.watch(refreshProvider);

    return PullToRefreshWrapper(
      onRefresh: () => refreshService.refreshHomeData(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Featured recipe section
            _buildFeaturedRecipe(context, ref),
            
            // Categories section
            _buildCategoriesSection(context, ref),
            
            // Popular recipes section
            Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Text(
                'Popular Recipes',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            
            // Recipe grid with actual data
            SizedBox(
              height: 600, // Fixed height for the grid
              child: filteredRecipesAsync.when(
                data: (recipes) => recipes.isEmpty
                    ? EmptyState(
                        icon: Icons.search_off,
                        title: 'No Recipes Found',
                        message: AppConstants.noResultsMessage,
                        actionButton: ElevatedButton.icon(
                          onPressed: () => refreshService.refreshHomeData(),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Refresh'),
                        ),
                      )
                    : RecipeGrid(
                        recipes: recipes,
                        onRecipeTap: (recipe) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecipeDetailScreen(recipe: recipe),
                            ),
                          );
                        },
                      ),
                loading: () => const RecipeGrid(
                  recipes: [],
                  isLoading: true,
                ),
                error: (error, stackTrace) => ErrorState(
                  message: error.toString(),
                  onRetry: () => refreshService.refreshHomeData(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedRecipe(BuildContext context, WidgetRef ref) {
    // Watch the random recipe provider to get a featured recipe
    final randomRecipeAsync = ref.watch(randomRecipeProvider);

    return Container(
      height: 200,
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        color: Theme.of(context).colorScheme.primaryContainer,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: randomRecipeAsync.when(
        data: (recipe) {
          if (recipe == null) {
            return const Center(
              child: Text('No featured recipe available'),
            );
          }
          
          return Stack(
            fit: StackFit.expand,
            children: [
              // Recipe image
              Image.network(
                recipe.thumbnailUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 64,
                        color: Colors.grey,
                      ),
                    ),
                  );
                },
              ),
              
              // Gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                    stops: const [0.6, 1.0],
                  ),
                ),
              ),
              
              // Recipe info
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Featured badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Featured',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Recipe name
                      Text(
                        recipe.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                          shadows: [
                            Shadow(
                              blurRadius: 2,
                              color: Colors.black,
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      
                      // Category and area
                      Row(
                        children: [
                          Icon(
                            Icons.category,
                            color: Colors.white.withOpacity(0.8),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            recipe.category,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(
                            Icons.location_on,
                            color: Colors.white.withOpacity(0.8),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            recipe.area,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              // Clickable overlay
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RecipeDetailScreen(recipe: recipe),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load featured recipe',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => ref.invalidate(randomRecipeProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context, WidgetRef ref) {
    // Watch the categories provider to get all available categories
    final categoriesAsync = ref.watch(categoriesProvider);
    // Watch the category filter to highlight the selected category
    final selectedCategory = ref.watch(categoryFilterProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Text(
            AppConstants.categoriesTitle,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        SizedBox(
          height: 120,
          child: categoriesAsync.when(
            data: (categories) {
              if (categories.isEmpty) {
                return const Center(
                  child: Text('No categories available'),
                );
              }
              
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultPadding,
                ),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return CategoryCard(
                    category: category,
                    isSelected: category.name == selectedCategory,
                  );
                },
              );
            },
            loading: () => ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding,
              ),
              itemCount: 5, // Show 5 placeholders
              itemBuilder: (context, index) => const CategoryCardPlaceholder(),
            ),
            error: (error, stackTrace) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Error loading categories',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: () => ref.invalidate(categoriesProvider),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
