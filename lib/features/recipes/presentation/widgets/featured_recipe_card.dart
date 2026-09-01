import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/time_formatter.dart';
import '../../../../core/widgets/app_cached_image.dart';
import '../../domain/entities/recipe.dart';
import '../providers/recipe_providers.dart';

class FeaturedRecipeCard extends ConsumerWidget {
  final Recipe recipe;
  final VoidCallback onTap;
  final VoidCallback? onToggleFavorite;

  const FeaturedRecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    this.onToggleFavorite,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 240,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            AppCachedImage(
              imageUrl: recipe.imageUrl,
              fit: BoxFit.cover,
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.5),
                    Colors.black.withValues(alpha: 0.95),
                  ],
                  stops: const [0.0, 0.45, 1.0],
                ),
              ),
            ),
            // Badges Header
            Positioned(
              top: 14,
              left: 14,
              right: 14,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primaryOrange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star_rounded, size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'CHEF SPOTLIGHT',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      if (onToggleFavorite != null) {
                        onToggleFavorite!();
                      } else {
                        ref.read(recipeControllerProvider.notifier).toggleFavorite(recipe.id);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        recipe.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        size: 20,
                        color: recipe.isFavorite ? AppColors.nonVegRed : Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Recipe Details Footer
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: (recipe.isVegetarian ? AppColors.vegGreen : AppColors.nonVegRed)
                              .withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: recipe.isVegetarian ? AppColors.vegGreen : AppColors.nonVegRed,
                            width: 1.2,
                          ),
                        ),
                        child: Text(
                          recipe.isVegetarian ? 'VEG' : 'NON-VEG',
                          style: TextStyle(
                            color: recipe.isVegetarian ? AppColors.vegGreen : AppColors.nonVegRed,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            recipe.region,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(Icons.timer_outlined, size: 14, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        TimeFormatter.formatMinutes(recipe.totalTimeMinutes),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    recipe.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 14, color: AppColors.accentGold),
                      const SizedBox(width: 3),
                      Text(
                        recipe.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'by ${recipe.chefName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
