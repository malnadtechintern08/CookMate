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
    return RecipeModel(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      chefName: (map['chef_name'] as String?) ?? 'CookMate Chef',
      cuisine: (map['cuisine'] as String?) ?? 'Indian',
      imageUrl: map['image_url'] as String,
      prepTimeMinutes: (map['prep_time_minutes'] as num).toInt(),
      cookTimeMinutes: (map['cook_time_minutes'] as num).toInt(),
      servings: (map['servings'] as num).toInt(),
      difficulty: RecipeDifficulty.fromString(map['difficulty'] as String),
      categoryId: map['category_id'] as String,
      tags: (map['tags'] as String).split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList(),
      isFavorite: (map['is_favorite'] as num?) == 1,
      isCustom: (map['is_custom'] as num?) == 1,
      isVegetarian: (map['is_vegetarian'] as num?) != 0,
      rating: ((map['rating'] as num?) ?? 4.8).toDouble(),
      region: (map['region'] as String?) ?? 'Karnataka',
      subcategory: (map['subcategory'] as String?) ?? '',
      nutrition: (map['nutrition'] as String?) ?? '',
      createdAt: DateTime.tryParse(map['created_at'] as String) ?? DateTime.now(),
      ingredients: ingredients,
      instructions: instructions,
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
