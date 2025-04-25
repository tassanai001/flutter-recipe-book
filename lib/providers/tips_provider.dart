import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:recipe_book/data/local/preferences_storage.dart';
import 'package:recipe_book/providers/preferences_provider.dart';

/// Model class for app tips
class AppTip {
  final String id;
  final String title;
  final String description;
  final String screen;
  final bool isDismissible;

  const AppTip({
    required this.id,
    required this.title,
    required this.description,
    required this.screen,
    this.isDismissible = true,
  });
}

/// Provider for managing app tips
class TipsNotifier extends StateNotifier<List<String>> {
  final PreferencesStorage _preferencesStorage;
  
  TipsNotifier(this._preferencesStorage) : super([]) {
    _loadDismissedTips();
  }

  /// Load the list of dismissed tips from preferences
  Future<void> _loadDismissedTips() async {
    final dismissedTips = await _preferencesStorage.getDismissedTips();
    state = dismissedTips;
  }

  /// Check if a tip has been dismissed
  bool isTipDismissed(String tipId) {
    return state.contains(tipId);
  }

  /// Dismiss a tip
  Future<void> dismissTip(String tipId) async {
    if (!state.contains(tipId)) {
      final newState = [...state, tipId];
      await _preferencesStorage.saveDismissedTips(newState);
      state = newState;
    }
  }

  /// Reset all tips (for testing or user preference)
  Future<void> resetAllTips() async {
    await _preferencesStorage.saveDismissedTips([]);
    state = [];
  }
}

/// Provider for the tips state notifier
final tipsProvider = StateNotifierProvider<TipsNotifier, List<String>>((ref) {
  final preferencesStorage = ref.watch(preferencesStorageProvider);
  return TipsNotifier(preferencesStorage);
});

/// List of all available tips in the app
final allTipsProvider = Provider<List<AppTip>>((ref) {
  return [
    const AppTip(
      id: 'home_search',
      title: 'Search for Recipes',
      description: 'Tap the search icon to find recipes by name, ingredient, or category.',
      screen: 'home',
    ),
    const AppTip(
      id: 'recipe_detail_favorite',
      title: 'Save Your Favorites',
      description: 'Tap the heart icon to save recipes to your favorites for quick access later.',
      screen: 'detail',
    ),
    const AppTip(
      id: 'recipe_detail_video',
      title: 'Watch Tutorial Videos',
      description: 'Many recipes include video tutorials. Look for the play button to learn cooking techniques.',
      screen: 'detail',
    ),
    const AppTip(
      id: 'category_filter',
      title: 'Filter by Category',
      description: 'Tap on category chips to filter recipes and find exactly what you\'re looking for.',
      screen: 'home',
    ),
    const AppTip(
      id: 'pull_to_refresh',
      title: 'Pull to Refresh',
      description: 'Pull down on the recipe list to refresh and get the latest recipes.',
      screen: 'home',
    ),
  ];
});

/// Provider that filters tips for a specific screen that haven't been dismissed
final screenTipsProvider = Provider.family<List<AppTip>, String>((ref, screen) {
  final allTips = ref.watch(allTipsProvider);
  final dismissedTips = ref.watch(tipsProvider);
  
  return allTips
      .where((tip) => tip.screen == screen && !dismissedTips.contains(tip.id))
      .toList();
});
