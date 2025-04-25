import 'package:flutter/material.dart';

/// App-wide constants
class AppConstants {
  // API Constants
  static const String apiBaseUrl = 'https://www.themealdb.com/api/json/v1/1';
  
  // App Theme Constants
  static const Color primaryColor = Color(0xFF4CAF50);
  static const Color accentColor = Color(0xFF8BC34A);
  static const Color textColor = Color(0xFF212121);
  static const Color secondaryTextColor = Color(0xFF757575);
  static const Color dividerColor = Color(0xFFBDBDBD);
  static const Color errorColor = Color(0xFFE57373);
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 8.0;
  static const double cardElevation = 2.0;
  
  // Animation Constants
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  
  // Pagination Constants
  static const int pageSize = 20;
  
  // Search Constants
  static const Duration searchDebounceTime = Duration(milliseconds: 500);
  
  // Error Messages
  static const String networkErrorMessage = 'No internet connection. Please check your network.';
  static const String generalErrorMessage = 'Something went wrong. Please try again.';
  static const String noResultsMessage = 'No recipes found. Try a different search term.';
  static const String timeoutErrorMessage = 'Request timed out. Please try again.';
  
  // Storage Keys
  static const String favoritesKey = 'favorite_recipes';
  static const String themeKey = 'app_theme';
  
  // App Text
  static const String appName = 'Recipe Book';
  static const String homeScreenTitle = 'Discover Recipes';
  static const String searchScreenTitle = 'Search Recipes';
  static const String favoritesScreenTitle = 'My Favorites';
  static const String detailsScreenTitle = 'Recipe Details';
  static const String settingsScreenTitle = 'Settings';
  static const String categoriesTitle = 'Categories';
  static const String ingredientsTitle = 'Ingredients';
  static const String instructionsTitle = 'Instructions';
  static const String emptyFavoritesMessage = 'No favorite recipes yet. Tap the heart icon on a recipe to add it to your favorites.';
}

/// Theme data for light and dark modes
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppConstants.primaryColor,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppConstants.primaryColor,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: AppConstants.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppConstants.primaryColor,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppConstants.primaryColor.withOpacity(0.1),
      selectedColor: AppConstants.primaryColor,
      labelStyle: const TextStyle(color: AppConstants.textColor),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.smallPadding,
        vertical: 4.0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppConstants.primaryColor,
      brightness: Brightness.dark,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[900],
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      elevation: AppConstants.cardElevation,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: AppConstants.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppConstants.accentColor,
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppConstants.primaryColor.withOpacity(0.3),
      selectedColor: AppConstants.primaryColor,
      labelStyle: const TextStyle(color: Colors.white70),
      secondaryLabelStyle: const TextStyle(color: Colors.white),
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.smallPadding,
        vertical: 4.0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
    ),
  );
}
