## 📌 **High-Level Vision**
Build a modern, responsive mobile app for browsing, searching, and managing recipes, integrating real-time data from a public API and persistent local favorites. Designed for Flutter best practices, this app emphasizes maintainable architecture and leverages Riverpod for state management.


---

## 🏛️ **Architecture Overview**

### **1. Clean Architecture**
- **Presentation Layer**: Flutter Widgets & Screens, using Riverpod for state.
- **Domain Layer**: Business logic (use cases: fetch recipes, search, add/remove favorites).
- **Data Layer**: API services, local storage repositories, data models.

### **2. State Management**
- **Riverpod** (latest version)
  - **Providers**: Async data (API), favorites (local), filters, and search state.
  - **Scoped Providers**: Used to isolate search, filters, and favorites to relevant UI components.

### **3. Data Flow**
- **Remote Data**: Fetch recipes, details, and perform search via HTTP REST calls.
- **Local Data**: Store user favorites (minimal info) using `shared_preferences`.
- **Synchronization**: UI auto-updates on API response or favorite changes.

---

## 🚧 **Constraints**
- **API Limits**: Most public recipe APIs enforce request quotas—implement debounce on search, caching, and error states.
- **Offline Support**: App is read-only without internet except for favorites.
- **Performance**: Pagination for browsing; lazy-loading images.
- **Scalability**: Modular structure to allow for easy feature expansion.

---

## 🛠️ **Tech Stack & Tools**

### **Flutter Core**
- **Flutter**: Latest stable (Flutter 3.19.3)
- **Dart**: Latest stable (Dart 3.3.1)

### **State Management**
- **Riverpod**: For all state, including async (API) and sync (favorites/filters).

### **Networking**
- **dio**: REST API integration.

### **Persistence**
- **shared_preferences**: For lightweight local favorites.

### **UI/UX**
- **flutter_hooks** *(optional)*: For cleaner provider consumption.
- **cached_network_image**: Efficient image loading.
- **responsive_builder**: For tablet/mobile UI.

### **Testing**
- **flutter_test**
- **mocktail**: For mocking API/services.

### **Code Quality**
- **flutter_lints**: Enforce coding standards.

### **API**
- **TheMealDB** (https://www.themealdb.com/api.php)
  *(or Spoonacular if you register for an API key)*

---

## 📝 **Core Features & Suggested Providers**

### **1. Recipe Browsing & Pagination**
- `recipesProvider`: AsyncNotifierProvider for paginated recipe lists.
- **Pagination**: Load more on scroll.

### **2. Search & Filters**
- `searchQueryProvider`: StateProvider for user input.
- `filteredRecipesProvider`: Combines search/filter with recipesProvider.
- `categoryFilterProvider`: StateProvider for selected categories.

### **3. Favorites Management**
- `favoritesProvider`: NotifierProvider for local favorite recipes.
- Uses local storage (`shared_preferences`).

### **4. Detailed Recipe View**
- `recipeDetailProvider`: FutureProvider.family for fetching details by ID.

---

## 🖥️ **Folder Structure Example**
```
lib/
  models/
  data/          // API and local data sources
  providers/
  screens/
  widgets/
  utils/
```

---

## 🔄 **High-Level Data Flow Example**

1. **User opens app**
   - App fetches and displays paginated recipes using `recipesProvider`.
2. **User searches or applies filter**
   - `searchQueryProvider` and/or `categoryFilterProvider` update state, recipes refetched as needed.
3. **User taps on a recipe**
   - `recipeDetailProvider` fetches full data for selected recipe.
4. **User favorites a recipe**
   - `favoritesProvider` updates state and persists change locally.
5. **User views favorites**
   - Loads from local storage, combines with remote data for updated details (optional).

---

## ⚡ **Learning Focus Implementation**
- **Pagination:** Use offset/limit API parameters, update provider with page state.
- **Search:** Debounce input; trigger provider updates only after user stops typing.
- **Riverpod Async Providers:** Handle loading, error, and success states in UI.
- **Combining local & remote storage:** Merge favorites with up-to-date API info for consistency.

---

## 💡 **Bonus Suggestions**
- Add a settings screen (theme switch, clear favorites)
- Include pull-to-refresh
- Implement error states and empty state UIs

---