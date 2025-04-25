/// A model class for managing pagination state
class PaginationState {
  /// Current page number (0-based)
  final int page;
  
  /// Number of items per page
  final int pageSize;
  
  /// Total number of items available (if known)
  final int? totalItems;
  
  /// Whether there are more items to load
  final bool hasMore;
  
  /// Whether the current page is being loaded
  final bool isLoading;
  
  /// Whether all items have been loaded
  bool get isComplete => !hasMore;

  const PaginationState({
    this.page = 0,
    this.pageSize = 10,
    this.totalItems,
    this.hasMore = true,
    this.isLoading = false,
  });

  /// Creates a copy of this state with the given fields replaced
  PaginationState copyWith({
    int? page,
    int? pageSize,
    int? totalItems,
    bool? hasMore,
    bool? isLoading,
  }) {
    return PaginationState(
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      totalItems: totalItems ?? this.totalItems,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// Returns the next page state
  PaginationState nextPage() {
    return copyWith(
      page: page + 1,
      isLoading: true,
    );
  }

  /// Returns the state with loading completed
  PaginationState loadingComplete({bool? hasMoreItems}) {
    return copyWith(
      isLoading: false,
      hasMore: hasMoreItems ?? hasMore,
    );
  }

  /// Returns the initial loading state
  PaginationState startLoading() {
    return copyWith(isLoading: true);
  }

  /// Returns the reset state (back to first page)
  PaginationState reset() {
    return PaginationState(pageSize: pageSize);
  }

  /// Calculate the offset for API requests
  int get offset => page * pageSize;

  @override
  String toString() {
    return 'PaginationState(page: $page, pageSize: $pageSize, totalItems: $totalItems, hasMore: $hasMore, isLoading: $isLoading)';
  }
}

/// A model class for paginated results
class PaginatedResult<T> {
  /// The items in the current page
  final List<T> items;
  
  /// The pagination state
  final PaginationState pagination;

  const PaginatedResult({
    required this.items,
    required this.pagination,
  });

  /// Creates a copy of this result with the given fields replaced
  PaginatedResult<T> copyWith({
    List<T>? items,
    PaginationState? pagination,
  }) {
    return PaginatedResult<T>(
      items: items ?? this.items,
      pagination: pagination ?? this.pagination,
    );
  }

  /// Appends new items to the existing list
  PaginatedResult<T> appendItems(List<T> newItems, {bool? hasMore}) {
    return PaginatedResult<T>(
      items: [...items, ...newItems],
      pagination: pagination.loadingComplete(hasMoreItems: hasMore),
    );
  }

  /// Creates an empty result with the given pagination state
  static PaginatedResult<T> empty<T>({PaginationState? pagination}) {
    return PaginatedResult<T>(
      items: [],
      pagination: pagination ?? const PaginationState(),
    );
  }
}
