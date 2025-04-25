import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_book/utils/constants.dart';
import 'package:recipe_book/utils/debouncer.dart';

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
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
          ),
        ),

        // Filter chips
        _buildFilterChips(),

        // Search results
        Expanded(
          child: Center(
            child: Text('Search results will appear here'),
          ),
        ),
      ],
    );
  }

  void _onSearchChanged(String query) {
    _debouncer.run(() {
      // This will be implemented later with proper provider updates
      // ref.read(searchQueryProvider.notifier).setQuery(query);
    });
  }

  void _clearSearch() {
    _searchController.clear();
    // This will be implemented later with proper provider updates
    // ref.read(searchQueryProvider.notifier).clearQuery();
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
      ),
      child: Row(
        children: [
          _buildFilterChip('Beef', true),
          _buildFilterChip('Chicken', false),
          _buildFilterChip('Dessert', false),
          _buildFilterChip('Lamb', false),
          _buildFilterChip('Pasta', false),
          _buildFilterChip('Seafood', false),
          _buildFilterChip('Vegetarian', false),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: AppConstants.smallPadding),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          // This will be implemented later with proper provider updates
          // ref.read(categoryFilterProvider.notifier).setCategory(selected ? label : null);
        },
      ),
    );
  }
}
