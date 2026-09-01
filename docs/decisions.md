# Architecture Decision Records (ADRs)

## ADR 1: Feature-First Clean Architecture
- **Status**: Accepted
- **Context**: The app required a scalable, testable, and maintainable architecture for recipe management, interactive cooking, custom recipe building, and category filtering.
- **Decision**: Adopt Feature-First Clean Architecture (`features/recipes/`, `features/categories/`, `features/cooking_mode/`, `features/favorites/`, `features/settings/`) with explicit separation across Presentation, Domain, and Data layers.
- **Consequences**: Strict boundary enforcement prevents UI from directly coupling to the SQLite engine or infrastructure.

## ADR 2: State Management with Riverpod
- **Status**: Accepted
- **Context**: Needed fine-grained reactivity, dependency injection, and declarative state across async database operations and cooking countdown timers.
- **Decision**: Use `flutter_riverpod` (v2) with dedicated `StateNotifierProvider`, `FutureProvider.family`, and custom notifiers for search filtering, theme toggling, and interactive cooking sessions.
- **Consequences**: Testable business logic without requiring BuildContext in presenters.

## ADR 3: Offline-First Local Storage Engine
- **Status**: Accepted
- **Context**: The app must operate 100% offline without backend servers, supporting rich relationships (recipes -> ingredients -> instruction steps).
- **Decision**: Use `sqflite` (with FFI fallback on desktop) and `shared_preferences` for theme settings.
- **Consequences**: Fast indexed queries, full-text search across titles/ingredients, atomic batch inserts and cascading deletions for custom recipes.

## ADR 4: Declarative Routing with GoRouter
- **Status**: Accepted
- **Context**: Multi-tab bottom navigation combined with deep-level recipe detail, cooking mode, and filter modals.
- **Decision**: Implement `GoRouter` with `StatefulShellRoute.indexedStack` for bottom navigation tabs and typed sub-routes.
- **Consequences**: Smooth state preservation when switching tabs.
