import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/category.dart';

class CategoryCardWidget extends StatelessWidget {
  final Category category;
  final VoidCallback onTap;
  final bool isSelected;
  final bool isCompact;

  const CategoryCardWidget({
    super.key,
    required this.category,
    required this.onTap,
    this.isSelected = false,
    this.isCompact = false,
  });

  IconData _getIconData(String name) {
    switch (name) {
      case 'local_pizza':
        return Icons.local_pizza_rounded;
      case 'ramen_dining':
        return Icons.ramen_dining_rounded;
      case 'soup_kitchen':
        return Icons.soup_kitchen_rounded;
      case 'fastfood':
        return Icons.fastfood_rounded;
      case 'restaurant_menu':
        return Icons.restaurant_menu_rounded;
      case 'timer':
        return Icons.timer_outlined;
      case 'eco':
        return Icons.eco_rounded;
      case 'cake':
        return Icons.cake_rounded;
      default:
        return Icons.restaurant_rounded;
    }
  }

  Color _parseColor(String hex) {
    try {
      final value = int.parse(hex.replaceFirst('0x', ''), radix: 16);
      return Color(value);
    } catch (_) {
      return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _parseColor(category.colorHex);

    if (isCompact) {
      return GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? color
                : (isDark ? AppColors.darkSurfaceCard : Colors.white),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? color
                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
              width: 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getIconData(category.iconName),
                size: 16,
                color: isSelected ? Colors.white : color,
              ),
              const SizedBox(width: 6),
              Text(
                category.name.split(' ').first,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected
                      ? Colors.white
                      : (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
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
            final isNarrow = constraints.maxWidth < 155;
            return Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    color.withValues(alpha: isDark ? 0.25 : 0.12),
                    isDark ? AppColors.darkSurfaceCard : Colors.white,
                  ],
                ),
              ),
              padding: EdgeInsets.all(isNarrow ? 12 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.all(isNarrow ? 8 : 10),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          _getIconData(category.iconName),
                          color: color,
                          size: isNarrow ? 20 : 24,
                        ),
                      ),
                      Flexible(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isNarrow ? 6 : 8,
                            vertical: 3.5,
                          ),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            ),
                          ),
                          child: Text(
                            isNarrow ? '${category.recipeCount}' : '${category.recipeCount} recipes',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: isNarrow ? 10 : 11,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: isNarrow ? 6 : 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isNarrow ? 14 : 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        category.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: isNarrow ? 11 : 12,
                          height: 1.25,
                          color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
