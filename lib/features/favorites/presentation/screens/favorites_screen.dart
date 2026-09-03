import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cookmate/app/router/route_names.dart';
import 'package:cookmate/app/router/route_paths.dart';
import 'package:cookmate/core/theme/app_colors.dart';
import 'package:cookmate/core/widgets/app_empty_state.dart';
import 'package:cookmate/core/widgets/app_error_state.dart';
import 'package:cookmate/core/widgets/app_loading_indicator.dart';
import 'package:cookmate/features/recipes/domain/entities/recipe.dart';
import 'package:cookmate/features/recipes/presentation/providers/recipe_providers.dart';
import 'package:cookmate/features/recipes/presentation/widgets/recipe_card.dart';
import 'package:cookmate/l10n/app_localizations.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoriteRecipesProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.favoriteRecipes),
      ),
      body: RefreshIndicator(
        color: AppColors.primaryOrange,
        onRefresh: () async {
          await ref.read(syncRecipesWithServerProvider.future).catchError((_) => <Recipe>[]);
          ref.invalidate(favoriteRecipesProvider);
        },
        child: favoritesAsync.when(
          data: (favorites) {
            if (favorites.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 80),
                  AppEmptyState(
                    icon: Icons.favorite_border_rounded,
                    title: l10n.noFavoritesTitle,
                    description: l10n.noFavoritesDesc,
                    actionLabel: l10n.exploreRecipesBtn,
                    onAction: () => context.go(RoutePaths.home),
                  ),
                ],
              );
            }

            return GridView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
                childAspectRatio: 0.78,
              ),
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final recipe = favorites[index];
                return RecipeCard(
                  recipe: recipe,
                  onTap: () {
                    context.pushNamed(
                      RouteNames.recipeDetail,
                      pathParameters: {'id': recipe.id},
                    );
                  },
                  onToggleFavorite: () {
                    ref.read(recipeControllerProvider.notifier).toggleFavorite(recipe.id);
                  },
                );
              },
            );
          },
          loading: () => const AppLoadingIndicator(),
          error: (err, _) => AppErrorState(
            message: err.toString(),
            onRetry: () => ref.refresh(favoriteRecipesProvider),
          ),
        ),
      ),
    );
  }
}
