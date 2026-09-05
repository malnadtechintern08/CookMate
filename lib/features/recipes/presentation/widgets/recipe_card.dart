import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/localization/recipe_translations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/time_formatter.dart';
import '../../../../core/widgets/app_cached_image.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/recipe.dart';
import '../providers/recipe_providers.dart';

class RecipeCard extends ConsumerWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final VoidCallback? onToggleFavorite;
  final bool isHorizontal;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    this.onToggleFavorite,
    this.isHorizontal = false,
  });

  Color _getDifficultyColor(RecipeDifficulty difficulty) {
    switch (difficulty) {
      case RecipeDifficulty.easy:
        return AppColors.vegGreen;
      case RecipeDifficulty.medium:
        return AppColors.warning;
      case RecipeDifficulty.hard:
        return AppColors.nonVegRed;
    }
  }

  String _getDifficultyLabel(RecipeDifficulty difficulty, AppLocalizations l10n) {
    switch (difficulty) {
      case RecipeDifficulty.easy:
        return l10n.easy;
      case RecipeDifficulty.medium:
        return l10n.medium;
      case RecipeDifficulty.hard:
        return l10n.hard;
    }
  }

  Widget _buildVegBadge(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isVeg = recipe.isVegetarian;
    final color = isVeg ? AppColors.vegGreen : AppColors.nonVegRed;

    return Container(
      padding: const EdgeInsets.all(2.5),
      decoration: BoxDecoration(
        color: (isDark ? AppColors.darkBackground : Colors.white).withValues(alpha: 0.9),
        border: Border.all(color: color, width: 1.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context, WidgetRef ref, {bool isNarrow = false}) {
    final l10n = AppLocalizations.of(context)!;
    return Stack(
      children: [
        AspectRatio(
          aspectRatio: isHorizontal ? 1.0 : (isNarrow ? 1.48 : 1.38),
          child: AppCachedImage(
            imageUrl: recipe.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        // Veg / Non-Veg badge top left
        Positioned(
          top: 8,
          left: 8,
          child: _buildVegBadge(context),
        ),
        // Favorite button overlay top right
        Positioned(
          top: 6,
          right: 6,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                if (onToggleFavorite != null) {
                  onToggleFavorite!();
                } else {
                  ref.read(recipeControllerProvider.notifier).toggleFavorite(recipe.id);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  recipe.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  size: 16,
                  color: recipe.isFavorite ? AppColors.nonVegRed : Colors.white,
                ),
              ),
            ),
          ),
        ),
        // Difficulty & Cooking Time Pill bottom
        Positioned(
          bottom: 6,
          left: 6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.72),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(recipe.difficulty),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  _getDifficultyLabel(recipe.difficulty, l10n),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final displayTitle = recipe.localizedTitle(context);

    if (isHorizontal) {
      return Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Row(
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: _buildImage(context, ref),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              recipe.cuisine.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryOrange,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const Icon(Icons.star_rounded, size: 14, color: AppColors.accentGold),
                          const SizedBox(width: 2),
                          Text(
                            recipe.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isDark ? AppColors.white : AppColors.lightTextPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        displayTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.white : AppColors.lightTextPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 13,
                            color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            TimeFormatter.formatMinutes(recipe.totalTimeMinutes),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              recipe.region,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.textMuted : AppColors.lightTextMuted,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (recipe.tags.isNotEmpty) ...[
                        const SizedBox(height: 5),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const NeverScrollableScrollPhysics(),
                          child: Row(
                            children: recipe.tags.take(3).map((raw) {
                              final clean = raw.trim().toLowerCase().replaceAll('#', '').replaceAll(' ', '_');
                              if (clean.isEmpty) return const SizedBox.shrink();
                              return Container(
                                margin: const EdgeInsets.only(right: 5),
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '#$clean',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final cardWidth = constraints.maxWidth;
            final isNarrow = cardWidth < 185;
            final bool hasBoundedHeight = constraints.hasBoundedHeight;
            final double? maxHeight = hasBoundedHeight ? constraints.maxHeight : null;
            final bool isTightHeight = maxHeight != null && maxHeight < 215;

            final detailsContent = Padding(
              padding: EdgeInsets.fromLTRB(
                isNarrow ? 8 : 10,
                isTightHeight ? 4 : 6,
                isNarrow ? 8 : 10,
                isTightHeight ? 4 : 7,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 13, color: AppColors.accentGold),
                      const SizedBox(width: 2),
                      Text(
                        recipe.rating.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: isNarrow ? 10.5 : 11.5,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.white : AppColors.lightTextPrimary,
                        ),
                      ),
                      const Spacer(),
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.timer_outlined,
                              size: isNarrow ? 11 : 13,
                              color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                            ),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                TimeFormatter.formatMinutes(recipe.totalTimeMinutes),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: isNarrow ? 10.5 : 11.5,
                                  color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isTightHeight ? 3 : 5),
                  Text(
                    displayTitle,
                    maxLines: isTightHeight ? 1 : 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isNarrow ? 11.5 : 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.white : AppColors.lightTextPrimary,
                      height: 1.15,
                    ),
                  ),
                  SizedBox(height: isTightHeight ? 2 : 3),
                  Text(
                    recipe.region.isNotEmpty ? recipe.region : recipe.cuisine,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isNarrow ? 10 : 11,
                      color: isDark ? AppColors.textMuted : AppColors.lightTextMuted,
                    ),
                  ),
                  if (recipe.tags.isNotEmpty && !isTightHeight && (!hasBoundedHeight || constraints.maxHeight >= 240)) ...[
                    const SizedBox(height: 3),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const NeverScrollableScrollPhysics(),
                      child: Row(
                        children: recipe.tags.take(2).map((raw) {
                          final clean = raw.trim().toLowerCase().replaceAll('#', '').replaceAll(' ', '_');
                          if (clean.isEmpty) return const SizedBox.shrink();
                          return Container(
                            margin: const EdgeInsets.only(right: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              '#$clean',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ],
              ),
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildImage(context, ref, isNarrow: isNarrow),
                hasBoundedHeight ? Expanded(child: detailsContent) : detailsContent,
              ],
            );
          },
        ),
      ),
    );
  }
}
