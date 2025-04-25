# Flutter Recipe Book

A modern, responsive mobile app for browsing, searching, and managing recipes, built with Flutter and following clean architecture principles.

## 📱 Features

- Browse recipes with pagination support
- Search recipes by name, ingredients, or category
- Filter recipes by category and cuisine
- View detailed recipe information
- Save favorite recipes for offline access
- Modern, responsive UI for both phones and tablets

## 🏛️ Architecture

This project follows clean architecture principles with a clear separation of concerns:

- **Presentation Layer**: Flutter widgets and screens using Riverpod for state management
- **Domain Layer**: Business logic for recipe operations
- **Data Layer**: API services, local storage, and data models

## 🛠️ Tech Stack

- **Flutter**: 3.19.3
- **Dart**: 3.3.1
- **State Management**: Riverpod
- **Networking**: dio for API integration
- **Local Storage**: shared_preferences for favorites
- **UI Components**: cached_network_image, responsive_builder
- **API**: TheMealDB

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
  │   └── favorites/
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

As of April 25, 2025, we have completed the following:

### Core Infrastructure
- ✅ Project setup with clean architecture folder structure
- ✅ Dependency configuration with Riverpod, dio, shared_preferences, etc.
- ✅ Data models for Recipe and Category
- ✅ API service for TheMealDB integration
- ✅ Local storage service for favorites management
- ✅ Repository layer to abstract data sources
- ✅ Riverpod providers for state management

### UI Components
- ✅ Basic screen structure (Home, Search, Favorites, Detail)
- ✅ Recipe card and grid components
- ✅ Search bar with debounce functionality
- ✅ Category filter chips
- ✅ Error and empty state widgets
- ✅ Basic theme and styling

### Next Development Focus
- UI integration with providers
- Pull-to-refresh implementation
- Favorites functionality in UI
- Unit and widget testing
- Performance optimization

## 📚 Documentation

For more detailed information about the project architecture and design decisions, see [PLANNING.md](./PLANNING.md).

For current development status and upcoming tasks, see [TASKS.md](./TASKS.md).

## 🧪 Testing

The project includes unit tests, widget tests, and integration tests:

```
flutter test
```

## 📄 License

This project is licensed under the MIT License.