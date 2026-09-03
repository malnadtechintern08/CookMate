import '../../domain/entities/recipe_submission.dart';

class RecipeSubmissionModel extends RecipeSubmission {
  const RecipeSubmissionModel({
    required super.id,
    required super.recipeName,
    required super.description,
    required super.categoryId,
    super.categoryName,
    super.categoryColor,
    super.image,
    super.prepTime,
    super.cookTime,
    super.difficulty,
    super.servings,
    super.cuisine,
    super.foodType,
    super.notes,
    super.status,
    super.allowPublication,
    super.showAuthorName,
    super.authorDisplayName,
    super.adminNotes,
    super.rejectionReason,
    super.publishedRecipeId,
    required super.submittedAt,
    super.reviewedAt,
    super.tags,
    super.ingredientCount,
    super.stepCount,
    super.ingredients,
    super.steps,
  });

  factory RecipeSubmissionModel.fromJson(Map<String, dynamic> json) {
    // Parse tags
    List<String> tagsList = [];
    if (json['tags'] is List) {
      tagsList = (json['tags'] as List).map((e) => e.toString()).toList();
    }

    // Parse ingredients if present
    List<SubmissionIngredient> ings = [];
    if (json['ingredients'] is List) {
      ings = (json['ingredients'] as List)
          .map((i) => SubmissionIngredient.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    // Parse steps if present
    List<SubmissionStep> stepsList = [];
    if (json['steps'] is List) {
      stepsList = (json['steps'] as List)
          .map((s) => SubmissionStep.fromJson(s as Map<String, dynamic>))
          .toList();
    }

    // Parse dates
    DateTime submittedDate;
    try {
      submittedDate = json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'].toString())
          : DateTime.now();
    } catch (_) {
      submittedDate = DateTime.now();
    }

    DateTime? reviewedDate;
    if (json['reviewed_at'] != null) {
      try {
        reviewedDate = DateTime.parse(json['reviewed_at'].toString());
      } catch (_) {}
    }

    return RecipeSubmissionModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      recipeName: json['recipe_name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      categoryId: json['category_id']?.toString() ?? '',
      categoryName: json['category_name']?.toString() ?? 'General',
      categoryColor: json['category_color']?.toString() ?? '#E50914',
      image: json['image']?.toString(),
      prepTime: (json['preparation_time'] as num?)?.toInt() ?? 15,
      cookTime: (json['cooking_time'] as num?)?.toInt() ?? 20,
      difficulty: json['difficulty']?.toString() ?? 'Medium',
      servings: (json['servings'] as num?)?.toInt() ?? 4,
      cuisine: json['cuisine']?.toString() ?? 'Homemade',
      foodType: json['food_type']?.toString() ?? 'Vegetarian',
      notes: json['notes']?.toString(),
      status: SubmissionStatus.fromString(json['status']?.toString()),
      allowPublication: json['allow_publication'] == true ||
          json['allow_publication'] == 1 ||
          json['allow_publication'] == '1',
      showAuthorName: json['show_author_name'] == true ||
          json['show_author_name'] == 1 ||
          json['show_author_name'] == '1',
      authorDisplayName: json['author_display_name']?.toString(),
      adminNotes: json['admin_notes']?.toString(),
      rejectionReason: json['rejection_reason']?.toString(),
      publishedRecipeId: json['published_recipe_id']?.toString(),
      submittedAt: submittedDate,
      reviewedAt: reviewedDate,
      tags: tagsList,
      ingredientCount: (json['ingredient_count'] as num?)?.toInt() ?? ings.length,
      stepCount: (json['step_count'] as num?)?.toInt() ?? stepsList.length,
      ingredients: ings,
      steps: stepsList,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'recipe_name': recipeName,
    'description': description,
    'category_id': categoryId,
    'category_name': categoryName,
    'category_color': categoryColor,
    'image': image,
    'preparation_time': prepTime,
    'cooking_time': cookTime,
    'difficulty': difficulty,
    'servings': servings,
    'cuisine': cuisine,
    'food_type': foodType,
    'notes': notes,
    'status': status.dbValue,
    'allow_publication': allowPublication ? 1 : 0,
    'show_author_name': showAuthorName ? 1 : 0,
    'author_display_name': authorDisplayName,
    'admin_notes': adminNotes,
    'rejection_reason': rejectionReason,
    'published_recipe_id': publishedRecipeId,
    'submitted_at': submittedAt.toIso8601String(),
    'reviewed_at': reviewedAt?.toIso8601String(),
    'tags': tags,
    'ingredients': ingredients.map((i) => i.toJson()).toList(),
    'steps': steps.map((s) => s.toJson()).toList(),
  };
}
