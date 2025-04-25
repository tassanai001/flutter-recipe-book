## 🚀 **Active Work & Subtasks**

### **1. Project Setup & Foundation**
- [ ] Initialize Flutter project and set up Git repo
- [ ] Configure dependencies: Riverpod, http/dio, shared_preferences, cached_network_image, etc.
- [ ] Set up folder structure (`lib/models`, `lib/data`, `lib/providers`, etc.)
- [ ] Implement base themes and responsive layout
- [ ] Configure flutter_lints

---

### **2. Models & API Layer**
- [ ] Define Recipe and Category models (from API JSON)
- [ ] Build Recipe API service: fetch recipe list, fetch by ID, fetch categories, search
- [ ] Implement retry and timeout handling in dio
- [ ] Unit test API integration

---

### **3. Riverpod Providers**
- [ ] Create `recipesProvider` with pagination support
- [ ] Create `recipeDetailProvider` (FutureProvider.family for recipe details)
- [ ] Create `searchQueryProvider` and debounce logic
- [ ] Create `categoryFilterProvider`
- [ ] Combine to make `filteredRecipesProvider`
- [ ] Implement `favoritesProvider` using shared_preferences

---

### **4. UI: Screens & Widgets**
- [ ] Splash / loading screen
- [ ] Main recipes list screen (paginated)
- [ ] Search bar and filter chips
- [ ] Recipe detail screen
- [ ] Favorites screen
- [ ] Error/empty state widgets

---

### **5. User Interaction & State**
- [ ] Implement pull-to-refresh
- [ ] Allow adding/removing favorites (UI + persistence)
- [ ] Persist and load favorites from storage
- [ ] Combine favorite IDs with up-to-date remote data

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
- [ ] Update README and PLANNING.md with setup, usage, and architecture notes
- [ ] Document API endpoints and key Riverpod providers
- [ ] Track bugs or technical debt discovered during development

---

## 🏁 **Milestones**
- **M1:** Project scaffold & API integration working
- **M2:** Pagination, search, and detail view complete
- **M3:** Favorites and local persistence implemented
- **M4:** Full Riverpod state flows; UI polish & error handling
- **M5:** Testing coverage; ready for release/demo

---