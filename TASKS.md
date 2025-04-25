## 🚀 **Active Work & Subtasks**

### **1. Project Setup & Foundation**
- [x] Initialize Flutter project and set up Git repo (2025-04-25)
- [x] Configure dependencies: Riverpod, http/dio, shared_preferences, cached_network_image, etc. (2025-04-25)
- [x] Set up folder structure (`lib/models`, `lib/data`, `lib/providers`, etc.) (2025-04-25)
- [x] Implement base themes and responsive layout (2025-04-25)
- [x] Configure flutter_lints (2025-04-25)

---

### **2. Models & API Layer**
- [x] Define Recipe and Category models (from API JSON) (2025-04-25)
- [x] Build Recipe API service: fetch recipe list, fetch by ID, fetch categories, search (2025-04-25)
- [x] Implement retry and timeout handling in dio (2025-04-25)
- [ ] Unit test API integration

---

### **3. Riverpod Providers**
- [x] Create `recipesProvider` with pagination support (2025-04-25)
- [x] Create `recipeDetailProvider` (FutureProvider.family for recipe details) (2025-04-25)
- [x] Create `searchQueryProvider` and debounce logic (2025-04-25)
- [x] Create `categoryFilterProvider` (2025-04-25)
- [x] Combine to make `filteredRecipesProvider` (2025-04-25)
- [x] Implement `favoritesProvider` using shared_preferences (2025-04-25)

---

### **4. UI: Screens & Widgets**
- [x] Splash / loading screen (2025-04-25)
- [x] Main recipes list screen (paginated) (2025-04-25)
- [x] Search bar and filter chips (2025-04-25)
- [x] Recipe detail screen (2025-04-25)
- [x] Favorites screen (2025-04-25)
- [x] Error/empty state widgets (2025-04-25)

---

### **5. User Interaction & State**
- [x] Implement pull-to-refresh (2025-04-25)
- [x] Allow adding/removing favorites (UI + persistence) (2025-04-25)
- [x] Persist and load favorites from storage (2025-04-25)
- [x] Combine favorite IDs with up-to-date remote data (2025-04-25)

---

### **6. Testing**
- [ ] Write provider tests (unit and widget tests)
- [ ] Mock API/service tests
- [ ] Test pagination and search edge cases
- [ ] Test offline and error scenarios

---

### **7. Polish & Bonus Features**
- [ ] Add a settings screen (theme toggle, clear favorites)
- [ ] Optimize image loading and caching
- [ ] Improve performance for large lists (pagination, caching)
- [ ] Add onboarding or tips for first-time users

---

### **8. Documentation & Milestones**
- [x] Update README and PLANNING.md with setup, usage, and architecture notes (2025-04-25)
- [x] Document API endpoints and key Riverpod providers (2025-04-25)
- [ ] Track bugs or technical debt discovered during development

---

## 🏁 **Milestones**
- [x] **M1:** Project scaffold & API integration working (2025-04-25)
- [ ] **M2:** Pagination, search, and detail view complete
- [ ] **M3:** Favorites and local persistence implemented
- [ ] **M4:** Full Riverpod state flows; UI polish & error handling
- [ ] **M5:** Testing coverage; ready for release/demo

---

## 📝 **Next Steps**
- Complete the UI implementation with actual data from providers
- Implement pull-to-refresh functionality
- Add favorite toggling functionality in the UI
- Write unit tests for API and repository classes
- Implement proper error handling and loading states

---

## 🔍 **Discovered During Work**
- Need to consider API rate limits for TheMealDB
- Consider adding caching layer for API responses to improve performance
- UI needs refinement for tablet layouts