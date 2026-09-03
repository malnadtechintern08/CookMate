import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_empty_state.dart';
import '../../../../core/widgets/app_loading_indicator.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../recipes/domain/entities/recipe.dart';
import '../../../recipes/presentation/providers/recipe_providers.dart';
import '../../../recipes/presentation/widgets/recipe_card.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  String _selectedTagKey = 'all';

  final List<Map<String, dynamic>> _exploreTags = [
    {'key': 'all', 'icon': Icons.all_inclusive_rounded},
    {'key': 'malnad', 'icon': Icons.eco_rounded},
    {'key': 'breakfast', 'icon': Icons.breakfast_dining_rounded},
    {'key': 'lunch_dinner', 'icon': Icons.dinner_dining_rounded},
    {'key': 'non_veg', 'icon': Icons.kebab_dining_rounded},
    {'key': 'snacks', 'icon': Icons.fastfood_rounded},
    {'key': 'desserts', 'icon': Icons.cake_rounded},
    {'key': 'drinks', 'icon': Icons.local_cafe_rounded},
    {'key': 'healthy', 'icon': Icons.fitness_center_rounded},
    {'key': 'vegetarian', 'icon': Icons.spa_rounded},
  ];

  String _getTagLabel(String key, AppLocalizations l10n) {
    switch (key) {
      case 'all': return l10n.categoryAll;
      case 'malnad': return l10n.categoryMalnadSpecial;
      case 'breakfast': return l10n.categoryBreakfast;
      case 'lunch_dinner': return l10n.categoryLunchDinner;
      case 'non_veg': return l10n.categoryNonVeg;
      case 'snacks': return l10n.categorySnacks;
      case 'desserts': return l10n.categoryDesserts;
      case 'drinks': return l10n.categoryDrinks;
      case 'healthy': return l10n.categoryHealthy;
      case 'vegetarian': return l10n.categoryVegetarian;
      default: return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allRecipesAsync = ref.watch(allRecipesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.exploreRecipesTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.pushNamed(RouteNames.search),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.primaryOrange,
        onRefresh: () async {
          await ref.read(syncRecipesWithServerProvider.future).catchError((_) => <Recipe>[]);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
          // Banner for Malnad Heritage
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: GestureDetector(
                onTap: () => context.pushNamed(RouteNames.malnad),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1B4D2E),
                        Color(0xFF0E2816),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFF2E7D32), width: 1.2),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.eco_rounded, color: AppColors.primaryOrange, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.tasteOfMalnadSpecial,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              l10n.malnadHeritageBannerSub,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFFC8E6C9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.white70),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Horizontally Scrollable Tags
          SliverToBoxAdapter(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: _exploreTags.map((tag) {
                  final key = tag['key'] as String;
                  final isSelected = _selectedTagKey == key;
                  final label = _getTagLabel(key, l10n);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      avatar: Icon(
                        tag['icon'] as IconData,
                        size: 16,
                        color: isSelected ? Colors.white : AppColors.primaryOrange,
                      ),
                      selected: isSelected,
                      label: Text(label),
                      selectedColor: AppColors.primaryOrange,
                      backgroundColor: isDark ? AppColors.cardBackground : AppColors.lightSurfaceCard,
                      labelStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                        color: isSelected
                            ? Colors.white
                            : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primaryOrange
                            : (isDark ? AppColors.border : AppColors.lightBorder),
                      ),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _selectedTagKey = key;
                          });
                        }
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Recipe Results Grid
          allRecipesAsync.when(
            data: (recipes) {
              final filtered = _filterRecipes(recipes, _selectedTagKey);

              if (filtered.isEmpty) {
                return SliverFillRemaining(
                  child: AppEmptyState(
                    icon: Icons.search_off_rounded,
                    title: l10n.noMatchingTitle,
                    description: l10n.noMatchingDesc,
                  ),
                );
              }

              return SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 0.78,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final recipe = filtered[index];
                      return RecipeCard(
                        recipe: recipe,
                        onTap: () {
                          context.pushNamed(
                            RouteNames.recipeDetail,
                            pathParameters: {'id': recipe.id},
                          );
                        },
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),
              );
            },
            loading: () => const SliverFillRemaining(
              child: AppLoadingIndicator(),
            ),
            error: (err, _) => SliverFillRemaining(
              child: Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
      ),
    );
  }

  List<Recipe> _filterRecipes(List<Recipe> recipes, String tagKey) {
    switch (tagKey) {
      case 'all':
        return recipes;
      case 'malnad':
        return recipes
            .where((r) => r.categoryId == 'cat_malnad' || r.tags.contains('Malnad Special'))
            .toList();
      case 'breakfast':
        return recipes.where((r) => r.categoryId == 'cat_breakfast').toList();
      case 'lunch_dinner':
        return recipes.where((r) => r.categoryId == 'cat_lunch_dinner').toList();
      case 'non_veg':
        return recipes.where((r) => !r.isVegetarian).toList();
      case 'snacks':
        return recipes.where((r) => r.categoryId == 'cat_snacks').toList();
      case 'desserts':
        return recipes.where((r) => r.categoryId == 'cat_desserts').toList();
      case 'drinks':
        return recipes.where((r) => r.categoryId == 'cat_drinks').toList();
      case 'healthy':
        return recipes.where((r) => r.categoryId == 'cat_healthy').toList();
      case 'vegetarian':
        return recipes.where((r) => r.isVegetarian).toList();
      default:
        return recipes;
    }
  }
}
