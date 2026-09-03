import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../features/categories/presentation/screens/categories_screen.dart';
import '../../features/categories/presentation/screens/category_recipes_screen.dart';
import '../../features/cooking_mode/presentation/screens/cooking_mode_screen.dart';
import '../../features/explore/presentation/screens/explore_screen.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/notes/domain/entities/note.dart';
import '../../features/notes/presentation/screens/note_detail_screen.dart';
import '../../features/notes/presentation/screens/note_form_screen.dart';
import '../../features/notes/presentation/screens/notes_screen.dart';
import '../../features/recipes/domain/entities/recipe.dart';
import '../../features/recipes/presentation/screens/hashtag_results_screen.dart';
import '../../features/recipes/presentation/screens/home_screen.dart';
import '../../features/recipes/presentation/screens/malnad_screen.dart';
import '../../features/recipes/presentation/screens/my_recipes_screen.dart';
import '../../features/recipes/presentation/screens/recipe_detail_screen.dart';
import '../../features/recipes/presentation/screens/recipe_form_screen.dart';
import '../../features/recipes/presentation/screens/search_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/shopping/presentation/screens/shopping_screen.dart';
import '../../features/splash/presentation/screens/splash_screen.dart';
import '../../features/submissions/presentation/screens/my_submissions_screen.dart';
import '../../features/submissions/presentation/screens/submit_recipe_screen.dart';
import '../../l10n/app_localizations.dart';
import 'route_names.dart';
import 'route_paths.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RoutePaths.splash,
    routes: [
      // 1. Initial Splash Screen
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // 2. Main 5-Tab Navigation Shell
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNestedNavigation(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: 🏠 Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.home,
                name: RouteNames.home,
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // Branch 1: 🔍 Explore
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.explore,
                name: RouteNames.explore,
                builder: (context, state) => const ExploreScreen(),
              ),
            ],
          ),

          // Branch 2: ❤️ Favorites
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.favorites,
                name: RouteNames.favorites,
                builder: (context, state) => const FavoritesScreen(),
              ),
            ],
          ),

          // Branch 3: 🛒 Shopping
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.shopping,
                name: RouteNames.shopping,
                builder: (context, state) => const ShoppingScreen(),
              ),
            ],
          ),

          // Branch 4: ⚙️ More / My Kitchen
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RoutePaths.myRecipes,
                name: RouteNames.myRecipes,
                builder: (context, state) => const MyRecipesScreen(),
              ),
            ],
          ),
        ],
      ),

      // Standalone Fullscreen Routes
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.malnad,
        name: RouteNames.malnad,
        builder: (context, state) => const MalnadScreen(),
      ),

      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.recipeDetail,
        name: RouteNames.recipeDetail,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return RecipeDetailScreen(recipeId: id);
        },
      ),

      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.recipeCreate,
        name: RouteNames.recipeCreate,
        builder: (context, state) => const RecipeFormScreen(),
      ),

      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.cookingMode,
        name: RouteNames.cookingMode,
        builder: (context, state) {
          final recipe = state.extra as Recipe;
          return CookingModeScreen(recipe: recipe);
        },
      ),

      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.search,
        name: RouteNames.search,
        builder: (context, state) => const SearchScreen(),
      ),

      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.hashtagResults,
        name: RouteNames.hashtagResults,
        builder: (context, state) {
          final tag = state.pathParameters['tag'] ?? '';
          return HashtagResultsScreen(tag: tag);
        },
      ),

      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.categories,
        name: RouteNames.categories,
        builder: (context, state) => const CategoriesScreen(),
      ),

      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.categoryRecipes,
        name: RouteNames.categoryRecipes,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return CategoryRecipesScreen(categoryId: id);
        },
      ),

      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.settings,
        name: RouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
      ),

      // Notes Feature Routes
      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.notes,
        name: RouteNames.notes,
        builder: (context, state) => const NotesScreen(),
      ),

      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.noteDetail,
        name: RouteNames.noteDetail,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return NoteDetailScreen(noteId: id);
        },
      ),

      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.noteCreate,
        name: RouteNames.noteCreate,
        builder: (context, state) => const NoteFormScreen(),
      ),

      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.noteEdit,
        name: RouteNames.noteEdit,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          final note = state.extra as Note?;
          return NoteFormScreen(noteId: id, initialNote: note);
        },
      ),

      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.submitRecipe,
        name: RouteNames.submitRecipe,
        builder: (context, state) {
          final idParam = state.uri.queryParameters['id'];
          final id = idParam != null ? int.tryParse(idParam) : null;
          return SubmitRecipeScreen(editSubmissionId: id);
        },
      ),

      GoRoute(
        parentNavigatorKey: _rootNavigatorKey,
        path: RoutePaths.mySubmissions,
        name: RouteNames.mySubmissions,
        builder: (context, state) => const MySubmissionsScreen(),
      ),
    ],
  );
}

class ScaffoldWithNestedNavigation extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNestedNavigation({
    super.key,
    required this.navigationShell,
  });

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _goBranch,
        indicatorColor: AppColors.primaryOrange.withValues(alpha: 0.18),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
            label: l10n.navHome,
          ),
          NavigationDestination(
            icon: const Icon(Icons.explore_outlined),
            selectedIcon: const Icon(Icons.explore_rounded),
            label: l10n.navExplore,
          ),
          NavigationDestination(
            icon: const Icon(Icons.favorite_outline_rounded),
            selectedIcon: const Icon(Icons.favorite_rounded),
            label: l10n.navFavorites,
          ),
          NavigationDestination(
            icon: const Icon(Icons.shopping_cart_outlined),
            selectedIcon: const Icon(Icons.shopping_cart_rounded),
            label: l10n.navShopping,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings_rounded),
            label: l10n.navMore,
          ),
        ],
      ),
    );
  }
}
