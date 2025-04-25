import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_book/screens/favorites/favorites_screen.dart';
import 'package:recipe_book/screens/search/search_screen.dart';
import 'package:recipe_book/utils/constants.dart';

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

  @override
  Widget build(BuildContext context) {
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
              // Refresh the current screen
              // This will be implemented later with proper provider invalidation
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
}

/// The content of the home tab
class _HomeContent extends ConsumerWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Featured recipe section
          _buildFeaturedRecipe(context),
          
          // Categories section
          _buildCategoriesSection(context, ref),
          
          // Recent recipes section
          Padding(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Text(
              'Popular Recipes',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          
          // Recipe grid will be implemented later
          const SizedBox(
            height: 400,
            child: Center(
              child: Text('Recipe grid will appear here'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedRecipe(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        color: Theme.of(context).colorScheme.primaryContainer,
      ),
      child: const Center(
        child: Text('Featured Recipe'),
      ),
    );
  }

  Widget _buildCategoriesSection(BuildContext context, WidgetRef ref) {
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
          child: Center(
            child: Text('Categories will appear here'),
          ),
        ),
      ],
    );
  }
}
