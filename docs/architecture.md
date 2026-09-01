# CookMate Architecture Documentation

## 1. Overview
**CookMate** is built strictly using **Feature-First Clean Architecture**, the **Repository Pattern**, **Riverpod State Management**, and **GoRouter Navigation**. It is completely offline-first with an embedded SQLite persistence engine and SharedPreferences for theme and preferences.

---

## 2. Layered Architecture

```
                                  PRESENTATION LAYER
   +--------------------------------------------------------------------------------+
   |   UI Screens (Home, Categories, Recipe Details, Cooking Mode, Search, My Recipes)|
   |   Custom Widgets (RecipeCard, IngredientList, CookingTimer, CategoryCard)      |
   |   State Notifiers & Providers (Riverpod)                                       |
   +--------------------------------------------------------------------------------+
                                          |
                                          v
                                    DOMAIN LAYER
   +--------------------------------------------------------------------------------+
   |   Entities (Recipe, Ingredient, InstructionStep, Category)                     |
   |   Repository Interfaces (RecipeRepository, CategoryRepository)                 |
   |   Use Cases (GetAllRecipes, SearchRecipes, ToggleFavorite, CreateRecipe, etc.) |
   +--------------------------------------------------------------------------------+
                                          |
                                          v
                                     DATA LAYER
   +--------------------------------------------------------------------------------+
   |   Models (RecipeModel, IngredientModel, InstructionStepModel, CategoryModel)   |
   |   Repository Implementations (RecipeRepositoryImpl, CategoryRepositoryImpl)     |
   |   Data Sources (RecipeLocalDataSource, CategoryLocalDataSource)                |
   |   SQLite Database (DatabaseService with Foreign Keys & Indexes)                |
   +--------------------------------------------------------------------------------+
```

---

## 3. Dependency Inversion & Strict Rules
1. **No UI Direct Access to Database/Infrastructure**: UI components interact exclusively with Riverpod Providers, which invoke Domain Use Cases.
2. **Domain Isolation**: Domain entities and use cases are independent of Flutter UI libraries, SQL engines, or HTTP clients.
3. **Data Independence**: The SQLite data access implementation is hidden behind repository interfaces.

---

## 4. Key Components

### 4.1 Persistence Layer (`DatabaseService`)
- SQLite schema with 4 normalized tables: `categories`, `recipes`, `ingredients`, `instructions`.
- Cascading deletions for clean relationship management.
- Indexed columns (`category_id`, `is_favorite`, `is_custom`, `title`) for rapid querying and search debouncing.
- Automatic seeding on first install with curated world cuisines and master chef dishes.

### 4.2 State Management (`flutter_riverpod`)
- Immutable domain entities and models.
- Family providers for single entity caching (`recipeDetailProvider(id)`, `selectedCategoryByIdProvider(id)`).
- `RecipeSearchNotifier` for real-time multi-criteria filtering (query string, category ID, difficulty, max cooking time).
- `CookingSessionNotifier` managing active step navigation, checkable task states, and real-time step timers.
- `ThemeModeNotifier` managing instantaneous ThemeMode switching (Light / Dark / System).

### 4.3 Navigation (`GoRouter`)
- `StatefulShellRoute.indexedStack` managing persistent tab state across Explore, Categories, Favorites, and My Kitchen.
- Fullscreen sub-routes for Recipe Details, Custom Recipe Form, Cooking Mode, Search, and Category views.
