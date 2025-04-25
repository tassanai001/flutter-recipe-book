import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/recipe_repository.dart';
import '../models/pagination.dart';
import '../models/recipe.dart';

/// A state notifier for managing paginated recipes
/// This provides efficient loading of large lists with pagination
class PaginatedRecipesNotifier extends StateNotifier<PaginatedResult<Recipe>> {
  final RecipeRepository _repository;
  String? _currentCategory;
  String? _currentArea;
  String? _currentSearchQuery;

  PaginatedRecipesNotifier(this._repository)
      : super(PaginatedResult.empty<Recipe>());

  /// Loads the first page of recipes by category
  Future<void> loadRecipesByCategory(String category) async {
    // Reset state if category changed
    if (_currentCategory != category) {
      state = PaginatedResult.empty<Recipe>();
      _currentCategory = category;
      _currentArea = null;
      _currentSearchQuery = null;
    }

    // If already loading, don't start another load
    if (state.pagination.isLoading) return;

    // Start loading
    state = PaginatedResult(
      items: state.items,
      pagination: state.pagination.startLoading(),
    );

    try {
      // Load first page
      final result = await _repository.getRecipesByCategoryPaginated(
        category,
        const PaginationState(page: 0, pageSize: 10),
      );

      state = result;
    } catch (e) {
      // Handle error
      state = PaginatedResult(
        items: state.items,
        pagination: state.pagination.loadingComplete(hasMoreItems: false),
      );
    }
  }

  /// Loads the next page of recipes by category
  Future<void> loadMoreRecipesByCategory() async {
    // If no category selected, can't load more
    if (_currentCategory == null) return;

    // If already loading or no more items, don't load more
    if (state.pagination.isLoading || !state.pagination.hasMore) return;

    // Start loading next page
    state = PaginatedResult(
      items: state.items,
      pagination: state.pagination.nextPage(),
    );

    try {
      // Load next page
      final result = await _repository.getRecipesByCategoryPaginated(
        _currentCategory!,
        state.pagination,
      );

      // Append new items to existing list
      state = PaginatedResult(
        items: [...state.items, ...result.items],
        pagination: result.pagination.copyWith(
          page: state.pagination.page,
        ),
      );
    } catch (e) {
      // Handle error
      state = PaginatedResult(
        items: state.items,
        pagination: state.pagination.loadingComplete(hasMoreItems: false),
      );
    }
  }

  /// Loads the first page of recipes by area
  Future<void> loadRecipesByArea(String area) async {
    // Reset state if area changed
    if (_currentArea != area) {
      state = PaginatedResult.empty<Recipe>();
      _currentArea = area;
      _currentCategory = null;
      _currentSearchQuery = null;
    }

    // If already loading, don't start another load
    if (state.pagination.isLoading) return;

    // Start loading
    state = PaginatedResult(
      items: state.items,
      pagination: state.pagination.startLoading(),
    );

    try {
      // Load first page
      final result = await _repository.getRecipesByAreaPaginated(
        area,
        const PaginationState(page: 0, pageSize: 10),
      );

      state = result;
    } catch (e) {
      // Handle error
      state = PaginatedResult(
        items: state.items,
        pagination: state.pagination.loadingComplete(hasMoreItems: false),
      );
    }
  }

  /// Loads the next page of recipes by area
  Future<void> loadMoreRecipesByArea() async {
    // If no area selected, can't load more
    if (_currentArea == null) return;

    // If already loading or no more items, don't load more
    if (state.pagination.isLoading || !state.pagination.hasMore) return;

    // Start loading next page
    state = PaginatedResult(
      items: state.items,
      pagination: state.pagination.nextPage(),
    );

    try {
      // Load next page
      final result = await _repository.getRecipesByAreaPaginated(
        _currentArea!,
        state.pagination,
      );

      // Append new items to existing list
      state = PaginatedResult(
        items: [...state.items, ...result.items],
        pagination: result.pagination.copyWith(
          page: state.pagination.page,
        ),
      );
    } catch (e) {
      // Handle error
      state = PaginatedResult(
        items: state.items,
        pagination: state.pagination.loadingComplete(hasMoreItems: false),
      );
    }
  }

  /// Loads the first page of search results
  Future<void> searchRecipes(String query) async {
    // Reset state if query changed
    if (_currentSearchQuery != query) {
      state = PaginatedResult.empty<Recipe>();
      _currentSearchQuery = query;
      _currentCategory = null;
      _currentArea = null;
    }

    // If query is empty, reset state
    if (query.isEmpty) {
      state = PaginatedResult.empty<Recipe>();
      return;
    }

    // If already loading, don't start another load
    if (state.pagination.isLoading) return;

    // Start loading
    state = PaginatedResult(
      items: state.items,
      pagination: state.pagination.startLoading(),
    );

    try {
      // Load first page
      final result = await _repository.searchRecipesPaginated(
        query,
        const PaginationState(page: 0, pageSize: 10),
      );

      state = result;
    } catch (e) {
      // Handle error
      state = PaginatedResult(
        items: state.items,
        pagination: state.pagination.loadingComplete(hasMoreItems: false),
      );
    }
  }

  /// Loads the next page of search results
  Future<void> loadMoreSearchResults() async {
    // If no search query, can't load more
    if (_currentSearchQuery == null || _currentSearchQuery!.isEmpty) return;

    // If already loading or no more items, don't load more
    if (state.pagination.isLoading || !state.pagination.hasMore) return;

    // Start loading next page
    state = PaginatedResult(
      items: state.items,
      pagination: state.pagination.nextPage(),
    );

    try {
      // Load next page
      final result = await _repository.searchRecipesPaginated(
        _currentSearchQuery!,
        state.pagination,
      );

      // Append new items to existing list
      state = PaginatedResult(
        items: [...state.items, ...result.items],
        pagination: result.pagination.copyWith(
          page: state.pagination.page,
        ),
      );
    } catch (e) {
      // Handle error
      state = PaginatedResult(
        items: state.items,
        pagination: state.pagination.loadingComplete(hasMoreItems: false),
      );
    }
  }

  /// Refreshes the current data
  Future<void> refresh() async {
    if (_currentCategory != null) {
      await loadRecipesByCategory(_currentCategory!);
    } else if (_currentArea != null) {
      await loadRecipesByArea(_currentArea!);
    } else if (_currentSearchQuery != null && _currentSearchQuery!.isNotEmpty) {
      await searchRecipes(_currentSearchQuery!);
    }
  }
}
