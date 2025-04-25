# Flutter Recipe Book

A modern, responsive mobile app for browsing, searching, and managing recipes, built with Flutter and following clean architecture principles.

## 📱 Features

- Browse recipes with pagination support
- Search recipes by name, ingredients, or category
- Filter recipes by category and cuisine
- View detailed recipe information
- Save favorite recipes for offline access
- Modern, responsive UI for both phones and tablets
- Onboarding experience for first-time users
- Contextual tips system to guide users through app features
- Offline mode with cached data access
- Comprehensive error handling with connectivity awareness
- Dark mode support with theme toggling
- YouTube video integration for recipe tutorials

## 🏛️ Architecture

This project follows clean architecture principles with a clear separation of concerns:

- **Presentation Layer**: Flutter widgets and screens using Riverpod for state management
- **Domain Layer**: Business logic for recipe operations
- **Data Layer**: API services, local storage, and data models

## 🛠️ Tech Stack

- **Flutter**: 3.19.3
- **Dart**: 3.3.1
- **State Management**: Riverpod for clean, testable state management
- **Networking**: dio for API integration with caching and error handling
- **Local Storage**: shared_preferences for favorites and app settings
- **UI Components**: cached_network_image for efficient image loading, responsive_builder for adaptive layouts
- **API**: TheMealDB for recipe data
- **Testing**: flutter_test for unit and widget tests, mocktail for mocking
- **Logging**: logger for debug and error logging

## 📁 Project Structure

```
lib/
  ├── models/            # Data models
  ├── data/              # Data layer
  │   ├── api/           # API services
  │   ├── repositories/  # Repositories
  │   └── local/         # Local storage
  ├── providers/         # Riverpod providers
  ├── screens/           # UI screens
  │   ├── home/
  │   ├── detail/
  │   ├── search/
  │   ├── favorites/
  │   ├── settings/
  │   ├── splash/
  │   └── onboarding/
  ├── widgets/           # Reusable widgets
  │   └── common/
  └── utils/             # Utilities and constants
```

## 🚀 Getting Started

### Prerequisites

- Flutter 3.19.3 or higher
- Dart 3.3.1 or higher

### Installation

1. Clone the repository:
   ```
   git clone https://github.com/tassanai001/flutter-recipe-book.git
   ```

2. Navigate to the project directory:
   ```
   cd flutter-recipe-book
   ```

3. Install dependencies:
   ```
   flutter pub get
   ```

4. Run the app:
   ```
   flutter run
   ```

## 📝 Current Implementation Status

As of April 26, 2025, we have completed the following:

### Core Infrastructure
- ✅ Project setup with clean architecture folder structure
- ✅ Dependency configuration with Riverpod, dio, shared_preferences, etc.
- ✅ Data models for Recipe and Category
- ✅ API service for TheMealDB integration with caching and error handling
- ✅ Local storage service for favorites management
- ✅ Repository layer to abstract data sources
- ✅ Riverpod providers for state management
- ✅ Network-aware repository with offline caching
- ✅ Connectivity monitoring for offline mode support

### UI Components
- ✅ Complete screen structure (Home, Search, Favorites, Detail, Settings, Onboarding)
- ✅ Recipe card and grid components with pagination
- ✅ Search bar with debounce functionality
- ✅ Category filter chips
- ✅ Error and empty state widgets
- ✅ Responsive theme and styling for both light and dark modes
- ✅ Onboarding flow for first-time users
- ✅ In-app contextual tips system
- ✅ Connectivity-aware error handling
- ✅ Settings screen with theme toggle and data management options

### User Experience
- ✅ Pull-to-refresh implementation
- ✅ Favorites functionality with local persistence
- ✅ YouTube video integration for recipe tutorials
- ✅ Image caching and optimization
- ✅ Performance optimizations for large lists
- ✅ Offline mode with cached data access
- ✅ Graceful error handling with retry options
- ✅ Debounced search to respect API rate limits
- ✅ Smooth transitions and loading states

### Testing
- ✅ Unit tests for providers and repositories
- ✅ Widget tests for UI components
- ✅ Mock tests for API services
- ✅ Edge case and error handling tests
- ✅ Offline mode testing
- ✅ Pagination and state management tests

## 🔄 Key Riverpod Providers

The app uses several key providers for state management:

- **recipesProvider**: Manages paginated recipe lists
- **recipeDetailProvider**: Fetches detailed recipe information
- **searchQueryProvider**: Manages search input with debounce
- **categoryFilterProvider**: Handles category filtering
- **favoritesProvider**: Manages favorite recipes with local persistence
- **themeProvider**: Handles app theme switching
- **connectivityProvider**: Monitors network connectivity
- **tipsProvider**: Manages contextual user tips

## 🌐 API Integration

The app integrates with TheMealDB API with the following features:

- Efficient caching to minimize network requests
- Rate limit awareness with debounced searches
- Error handling with user-friendly messages
- Offline fallback to cached data
- Manual pagination implementation for APIs without native pagination

## 📄 License

This project is licensed under the MIT License.

## 📚 Documentation

For more detailed information about the project architecture and design decisions, see [PLANNING.md](./PLANNING.md).

For current development status and upcoming tasks, see [TASKS.md](./TASKS.md).

## 🧪 Testing

The project includes unit tests, widget tests, and integration tests:

```
flutter test
```