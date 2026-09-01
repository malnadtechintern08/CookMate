import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../l10n/app_localizations.dart';
import '../providers/recipe_providers.dart';
import '../widgets/recipe_card.dart';
import '../widgets/recipe_filter_bottom_sheet.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    final filter = ref.read(recipeFilterProvider);
    _searchController = TextEditingController(text: filter.query);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filterState = ref.watch(recipeFilterProvider);
    final searchResultsAsync = ref.watch(searchResultsProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: TextField(
            controller: _searchController,
            autofocus: true,
            decoration: InputDecoration(
              hintText: l10n.searchHint,
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryOrange),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        ref.read(recipeFilterProvider.notifier).setQuery('');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
            ),
            onChanged: (val) {
              ref.read(recipeFilterProvider.notifier).setQuery(val);
            },
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.filter_list_rounded,
              color: filterState.hasActiveFilters ? AppColors.primaryOrange : null,
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => const RecipeFilterBottomSheet(),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Active filter tags bar
          if (filterState.hasActiveFilters)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    if (filterState.difficulty != null)
                      _buildFilterBadge(l10n.filterDifficulty(filterState.difficulty!), () {
                        ref.read(recipeFilterProvider.notifier).setDifficulty(null);
                      }),
                    if (filterState.maxTimeMinutes != null)
                      _buildFilterBadge(l10n.filterMaxTime(filterState.maxTimeMinutes!), () {
                        ref.read(recipeFilterProvider.notifier).setMaxTime(null);
                      }),
                    if (filterState.categoryId != null)
                      _buildFilterBadge(l10n.filterCategory, () {
                        ref.read(recipeFilterProvider.notifier).setCategory(null);
                      }),
                    TextButton(
                      onPressed: () {
                        ref.read(recipeFilterProvider.notifier).resetFilters();
                        _searchController.clear();
                      },
                      child: Text(l10n.clearAllFilters, style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),

          // Search Results
          Expanded(
            child: searchResultsAsync.when(
              data: (recipes) {
                if (recipes.isEmpty) {
                  return AppEmptyState(
                    icon: Icons.search_off_rounded,
                    title: l10n.noMatchingTitle,
                    description: l10n.noMatchingDesc,
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: recipes.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return RecipeCard(
                      recipe: recipe,
                      isHorizontal: true,
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
              error: (err, stack) => Center(
                child: Text('Search Error: $err'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBadge(String label, VoidCallback onRemove) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.primaryOrange.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primaryOrange.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryOrange,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.close_rounded, size: 14, color: AppColors.primaryOrange),
          ),
        ],
      ),
    );
  }
}
