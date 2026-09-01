import 'ingredient.dart';
import 'instruction_step.dart';

enum RecipeDifficulty {
  easy,
  medium,
  hard;

  String get label {
    switch (this) {
      case RecipeDifficulty.easy:
        return 'Easy';
      case RecipeDifficulty.medium:
        return 'Medium';
      case RecipeDifficulty.hard:
        return 'Hard';
    }
  }

  static RecipeDifficulty fromString(String value) {
    switch (value.toLowerCase()) {
      case 'easy':
        return RecipeDifficulty.easy;
      case 'medium':
        return RecipeDifficulty.medium;
      case 'hard':
        return RecipeDifficulty.hard;
      default:
        return RecipeDifficulty.medium;
    }
  }
}

class Recipe {
  final String id;
  final String title;
  final String description;
  final String chefName;
  final String cuisine;
  final String imageUrl;
  final int prepTimeMinutes;
  final int cookTimeMinutes;
  final int servings;
  final RecipeDifficulty difficulty;
  final String categoryId;
  final List<String> tags;
  final bool isFavorite;
  final bool isCustom;
  final bool isVegetarian;
  final double rating;
  final String region;
  final String subcategory;
  final String nutrition;
  final DateTime createdAt;
  final List<Ingredient> ingredients;
  final List<InstructionStep> instructions;

  const Recipe({
    required this.id,
    required this.title,
    required this.description,
    required this.chefName,
    required this.cuisine,
    required this.imageUrl,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.servings,
    required this.difficulty,
    required this.categoryId,
    required this.tags,
    this.isFavorite = false,
    this.isCustom = false,
    this.isVegetarian = true,
    this.rating = 4.8,
    this.region = 'Karnataka',
    this.subcategory = '',
    this.nutrition = '',
    required this.createdAt,
    this.ingredients = const [],
    this.instructions = const [],
  });

  // Getters & Aliases for seamless developer ergonomics
  String get name => title;
  String get image => imageUrl;
  int get prepTime => prepTimeMinutes;
  int get cookTime => cookTimeMinutes;
  int get totalTime => prepTimeMinutes + cookTimeMinutes;
  int get totalTimeMinutes => prepTimeMinutes + cookTimeMinutes;

  Recipe copyWith({
    String? id,
    String? title,
    String? description,
    String? chefName,
    String? cuisine,
    String? imageUrl,
    int? prepTimeMinutes,
    int? cookTimeMinutes,
    int? servings,
    RecipeDifficulty? difficulty,
    String? categoryId,
    List<String>? tags,
    bool? isFavorite,
    bool? isCustom,
    bool? isVegetarian,
    double? rating,
    String? region,
    String? subcategory,
    String? nutrition,
    DateTime? createdAt,
    List<Ingredient>? ingredients,
    List<InstructionStep>? instructions,
  }) {
    return Recipe(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      chefName: chefName ?? this.chefName,
      cuisine: cuisine ?? this.cuisine,
      imageUrl: imageUrl ?? this.imageUrl,
      prepTimeMinutes: prepTimeMinutes ?? this.prepTimeMinutes,
      cookTimeMinutes: cookTimeMinutes ?? this.cookTimeMinutes,
      servings: servings ?? this.servings,
      difficulty: difficulty ?? this.difficulty,
      categoryId: categoryId ?? this.categoryId,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      isCustom: isCustom ?? this.isCustom,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      rating: rating ?? this.rating,
      region: region ?? this.region,
      subcategory: subcategory ?? this.subcategory,
      nutrition: nutrition ?? this.nutrition,
      createdAt: createdAt ?? this.createdAt,
      ingredients: ingredients ?? this.ingredients,
      instructions: instructions ?? this.instructions,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Recipe &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
