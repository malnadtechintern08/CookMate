import '../../domain/entities/recipe.dart';
import 'ingredient_model.dart';
import 'instruction_step_model.dart';

class RecipeModel extends Recipe {
  const RecipeModel({
    required super.id,
    required super.title,
    required super.description,
    required super.chefName,
    required super.cuisine,
    required super.imageUrl,
    required super.prepTimeMinutes,
    required super.cookTimeMinutes,
    required super.servings,
    required super.difficulty,
    required super.categoryId,
    required super.tags,
    super.isFavorite,
    super.isCustom,
    super.isVegetarian,
    super.rating,
    super.region,
    super.subcategory,
    super.nutrition,
    required super.createdAt,
    super.ingredients,
    super.instructions,
  });

  factory RecipeModel.fromMap(
    Map<String, dynamic> map, {
    List<IngredientModel> ingredients = const [],
    List<InstructionStepModel> instructions = const [],
  }) {
    int parseInt(dynamic val, [int fallback = 0]) {
      if (val is num) return val.toInt();
      if (val is String) return int.tryParse(val) ?? fallback;
      return fallback;
    }

    double parseDouble(dynamic val, [double fallback = 0.0]) {
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? fallback;
      return fallback;
    }

    bool parseBool(dynamic val, [bool fallback = false]) {
      if (val is bool) return val;
      if (val is num) return val == 1;
      if (val is String) return val == '1' || val.toLowerCase() == 'true';
      return fallback;
    }

    // Parse nested ingredients if present in JSON
    List<IngredientModel> parsedIngredients = List.from(ingredients);
    if (parsedIngredients.isEmpty && map['ingredients'] is List) {
      parsedIngredients = (map['ingredients'] as List)
          .map((i) => IngredientModel.fromMap(Map<String, dynamic>.from(i as Map)))
          .toList();
    }

    // Parse nested instructions if present in JSON
    List<InstructionStepModel> parsedInstructions = List.from(instructions);
    if (parsedInstructions.isEmpty && map['instructions'] is List) {
      parsedInstructions = (map['instructions'] as List)
          .map((s) => InstructionStepModel.fromMap(Map<String, dynamic>.from(s as Map)))
          .toList();
    }

    final rawTags = map['tags'];
    List<String> parsedTags = [];
    if (rawTags is List) {
      parsedTags = rawTags.map((t) => t.toString().trim()).where((t) => t.isNotEmpty).toList();
    } else if (rawTags is String) {
      parsedTags = rawTags.split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();
    }

    DateTime parsedDate = DateTime.now();
    if (map['created_at'] != null) {
      parsedDate = DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now();
    }

    return RecipeModel(
      id: map['id'].toString(),
      title: (map['title'] as String?) ?? '',
      description: (map['description'] as String?) ?? '',
      chefName: (map['chef_name'] as String?) ?? 'CookMate Chef',
      cuisine: (map['cuisine'] as String?) ?? 'Indian',
      imageUrl: (map['image_url'] as String?) ?? '',
      prepTimeMinutes: parseInt(map['prep_time_minutes'], 15),
      cookTimeMinutes: parseInt(map['cook_time_minutes'], 20),
      servings: parseInt(map['servings'], 4),
      difficulty: RecipeDifficulty.fromString(map['difficulty']?.toString() ?? 'Medium'),
      categoryId: (map['category_id'] as String?) ?? 'cat_other',
      tags: parsedTags,
      isFavorite: parseBool(map['is_favorite'], false),
      isCustom: parseBool(map['is_custom'], false),
      isVegetarian: parseBool(map['is_vegetarian'], true),
      rating: parseDouble(map['rating'], 4.8),
      region: (map['region'] as String?) ?? 'Karnataka',
      subcategory: (map['subcategory'] as String?) ?? '',
      nutrition: (map['nutrition'] as String?) ?? '',
      createdAt: parsedDate,
      ingredients: parsedIngredients,
      instructions: parsedInstructions,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'chef_name': chefName,
      'cuisine': cuisine,
      'image_url': imageUrl,
      'prep_time_minutes': prepTimeMinutes,
      'cook_time_minutes': cookTimeMinutes,
      'servings': servings,
      'difficulty': difficulty.label,
      'category_id': categoryId,
      'tags': tags.join(','),
      'is_favorite': isFavorite ? 1 : 0,
      'is_custom': isCustom ? 1 : 0,
      'is_vegetarian': isVegetarian ? 1 : 0,
      'rating': rating,
      'region': region,
      'subcategory': subcategory,
      'nutrition': nutrition,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
