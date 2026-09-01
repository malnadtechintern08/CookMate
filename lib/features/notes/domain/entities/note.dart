import '../../../../l10n/app_localizations.dart';

class NoteCategory {
  static const String recipeIdea = 'Recipe Idea';
  static const String shoppingReminder = 'Shopping Reminder';
  static const String mealPlan = 'Meal Plan';
  static const String kitchenTip = 'Kitchen Tip';
  static const String ingredientNote = 'Ingredient Note';
  static const String malnadRecipe = 'Malnad Recipe';
  static const String personalNote = 'Personal Note';
  static const String other = 'Other';

  static const List<String> allCategories = [
    recipeIdea,
    shoppingReminder,
    mealPlan,
    kitchenTip,
    ingredientNote,
    malnadRecipe,
    personalNote,
    other,
  ];

  static String getLocalizedName(String category, AppLocalizations l10n) {
    switch (category) {
      case recipeIdea:
        return l10n.catRecipeIdea;
      case shoppingReminder:
        return l10n.catShoppingReminder;
      case mealPlan:
        return l10n.catMealPlan;
      case kitchenTip:
        return l10n.catKitchenTip;
      case ingredientNote:
        return l10n.catIngredientNote;
      case malnadRecipe:
        return l10n.catMalnadRecipe;
      case personalNote:
        return l10n.catPersonalNote;
      case other:
      default:
        return l10n.catOther;
    }
  }
}

class Note {
  final String id;
  final String title;
  final String content;
  final String category;
  final List<String> tags;
  final bool isPinned;
  final bool isFavorite;
  final String? relatedRecipeId;
  final String? relatedRecipeTitle;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Note({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.tags = const [],
    this.isPinned = false,
    this.isFavorite = false,
    this.relatedRecipeId,
    this.relatedRecipeTitle,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get hasRelatedRecipe =>
      relatedRecipeId != null && relatedRecipeId!.isNotEmpty;

  String get snippet {
    final clean = content.replaceAll('\n', ' ').trim();
    if (clean.length <= 100) return clean;
    return '${clean.substring(0, 97)}...';
  }

  Note copyWith({
    String? id,
    String? title,
    String? content,
    String? category,
    List<String>? tags,
    bool? isPinned,
    bool? isFavorite,
    String? relatedRecipeId,
    String? relatedRecipeTitle,
    bool clearRelatedRecipe = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      isPinned: isPinned ?? this.isPinned,
      isFavorite: isFavorite ?? this.isFavorite,
      relatedRecipeId: clearRelatedRecipe ? null : (relatedRecipeId ?? this.relatedRecipeId),
      relatedRecipeTitle: clearRelatedRecipe ? null : (relatedRecipeTitle ?? this.relatedRecipeTitle),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Note &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          content == other.content &&
          category == other.category &&
          isPinned == other.isPinned &&
          isFavorite == other.isFavorite &&
          relatedRecipeId == other.relatedRecipeId &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      content.hashCode ^
      category.hashCode ^
      isPinned.hashCode ^
      isFavorite.hashCode ^
      relatedRecipeId.hashCode ^
      createdAt.hashCode ^
      updatedAt.hashCode;
}
