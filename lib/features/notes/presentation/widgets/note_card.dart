import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/note.dart';

class NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onTogglePin;
  final VoidCallback onToggleFavorite;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
    required this.onTogglePin,
    required this.onToggleFavorite,
  });

  Color _getCategoryColor(String category) {
    switch (category) {
      case NoteCategory.recipeIdea:
        return AppColors.primaryOrange;
      case NoteCategory.shoppingReminder:
        return AppColors.accentGold;
      case NoteCategory.mealPlan:
        return const Color(0xFF42A5F5);
      case NoteCategory.kitchenTip:
        return const Color(0xFFAB47BC);
      case NoteCategory.ingredientNote:
        return AppColors.vegGreen;
      case NoteCategory.malnadRecipe:
        return const Color(0xFF2E7D32);
      case NoteCategory.personalNote:
        return const Color(0xFFEC407A);
      case NoteCategory.other:
      default:
        return AppColors.warning;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case NoteCategory.recipeIdea:
        return Icons.lightbulb_outline_rounded;
      case NoteCategory.shoppingReminder:
        return Icons.shopping_cart_outlined;
      case NoteCategory.mealPlan:
        return Icons.calendar_today_rounded;
      case NoteCategory.kitchenTip:
        return Icons.tips_and_updates_outlined;
      case NoteCategory.ingredientNote:
        return Icons.eco_outlined;
      case NoteCategory.malnadRecipe:
        return Icons.forest_outlined;
      case NoteCategory.personalNote:
        return Icons.person_outline_rounded;
      case NoteCategory.other:
      default:
        return Icons.notes_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final catColor = _getCategoryColor(note.category);
    final catIcon = _getCategoryIcon(note.category);
    final catName = NoteCategory.getLocalizedName(note.category, l10n);
    final formattedDate = DateFormat('d MMM yyyy').format(note.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardBackground : AppColors.lightSurfaceCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: note.isPinned
              ? AppColors.primaryOrange.withValues(alpha: 0.5)
              : (isDark ? AppColors.border : AppColors.lightBorder),
          width: note.isPinned ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Pin Badge, Title, Favorite & Actions Menu
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (note.isPinned) ...[
                      const Padding(
                        padding: EdgeInsets.only(right: 6, top: 2),
                        child: Icon(
                          Icons.push_pin_rounded,
                          size: 16,
                          color: AppColors.primaryOrange,
                        ),
                      ),
                    ],
                    Expanded(
                      child: Text(
                        note.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDark ? AppColors.textPrimary : AppColors.lightTextPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Favorite icon button
                    GestureDetector(
                      onTap: onToggleFavorite,
                      child: Icon(
                        note.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        size: 20,
                        color: note.isFavorite ? AppColors.nonVegRed : (isDark ? AppColors.textMuted : AppColors.lightTextMuted),
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Popup 3-dot menu
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert_rounded,
                        size: 20,
                        color: isDark ? AppColors.textMuted : AppColors.lightTextMuted,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit();
                            break;
                          case 'pin':
                            onTogglePin();
                            break;
                          case 'favorite':
                            onToggleFavorite();
                            break;
                          case 'delete':
                            onDelete();
                            break;
                        }
                      },
                      itemBuilder: (ctx) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              const Icon(Icons.edit_outlined, size: 18, color: AppColors.primaryOrange),
                              const SizedBox(width: 8),
                              Text(l10n.editNote),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'pin',
                          child: Row(
                            children: [
                              Icon(
                                note.isPinned ? Icons.push_pin_outlined : Icons.push_pin_rounded,
                                size: 18,
                                color: AppColors.primaryOrange,
                              ),
                              const SizedBox(width: 8),
                              Text(note.isPinned ? l10n.unpin : l10n.pin),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'favorite',
                          child: Row(
                            children: [
                              Icon(
                                note.isFavorite ? Icons.favorite_border_rounded : Icons.favorite_rounded,
                                size: 18,
                                color: AppColors.nonVegRed,
                              ),
                              const SizedBox(width: 8),
                              Text(note.isFavorite ? l10n.favorite : l10n.favorite),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              const Icon(Icons.delete_outline_rounded, size: 18, color: AppColors.nonVegRed),
                              const SizedBox(width: 8),
                              Text(l10n.deleteNote, style: const TextStyle(color: AppColors.nonVegRed)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                if (note.content.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    note.snippet,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.45,
                      color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // Tags if any
                if (note.tags.isNotEmpty) ...[
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: note.tags.take(3).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.background : AppColors.lightBackground,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: isDark ? AppColors.border : AppColors.lightBorder),
                        ),
                        child: Text(
                          '#$tag',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textMuted : AppColors.lightTextMuted,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                ],

                // Bottom Meta: Category Pill + Date + Related Recipe
                Row(
                  children: [
                    // Category pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: catColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(catIcon, size: 12, color: catColor),
                          const SizedBox(width: 4),
                          Text(
                            catName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: catColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    if (note.hasRelatedRecipe) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primaryOrange.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.restaurant_menu_rounded, size: 12, color: AppColors.primaryOrange),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  note.relatedRecipeTitle ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primaryOrange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else
                      const Spacer(),

                    // Creation Date
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.textMuted : AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
