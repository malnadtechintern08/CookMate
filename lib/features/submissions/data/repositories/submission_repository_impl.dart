import '../../domain/entities/recipe_submission.dart';
import '../datasources/submission_remote_datasource.dart';

abstract class SubmissionRepository {
  Future<Map<String, dynamic>> submitRecipe({
    required String recipeName,
    required String description,
    required String categoryId,
    required int prepTime,
    required int cookTime,
    required int servings,
    required String difficulty,
    required String cuisine,
    required String foodType,
    String? notes,
    required bool allowPublication,
    required bool showAuthorName,
    String? authorDisplayName,
    String? imagePath,
    required List<Map<String, dynamic>> ingredients,
    required List<Map<String, dynamic>> steps,
    required List<String> tags,
  });

  Future<List<RecipeSubmission>> getMySubmissions();
  Future<RecipeSubmission> getSubmissionDetails(int id);
  Future<Map<String, dynamic>> updateSubmission({
    required int id,
    required String recipeName,
    required String description,
    required String categoryId,
    required int prepTime,
    required int cookTime,
    required int servings,
    required String difficulty,
    required String cuisine,
    required String foodType,
    String? notes,
    required bool allowPublication,
    required bool showAuthorName,
    String? authorDisplayName,
    String? imagePath,
    required List<Map<String, dynamic>> ingredients,
    required List<Map<String, dynamic>> steps,
    required List<String> tags,
  });
  Future<bool> withdrawSubmission(int id);
}

class SubmissionRepositoryImpl implements SubmissionRepository {
  final SubmissionRemoteDataSource remoteDataSource;

  SubmissionRepositoryImpl(this.remoteDataSource);

  @override
  Future<Map<String, dynamic>> submitRecipe({
    required String recipeName,
    required String description,
    required String categoryId,
    required int prepTime,
    required int cookTime,
    required int servings,
    required String difficulty,
    required String cuisine,
    required String foodType,
    String? notes,
    required bool allowPublication,
    required bool showAuthorName,
    String? authorDisplayName,
    String? imagePath,
    required List<Map<String, dynamic>> ingredients,
    required List<Map<String, dynamic>> steps,
    required List<String> tags,
  }) async {
    return await remoteDataSource.submitRecipe(
      recipeName: recipeName,
      description: description,
      categoryId: categoryId,
      prepTime: prepTime,
      cookTime: cookTime,
      servings: servings,
      difficulty: difficulty,
      cuisine: cuisine,
      foodType: foodType,
      notes: notes,
      allowPublication: allowPublication,
      showAuthorName: showAuthorName,
      authorDisplayName: authorDisplayName,
      imagePath: imagePath,
      ingredients: ingredients,
      steps: steps,
      tags: tags,
    );
  }

  @override
  Future<List<RecipeSubmission>> getMySubmissions() async {
    return await remoteDataSource.getMySubmissions();
  }

  @override
  Future<RecipeSubmission> getSubmissionDetails(int id) async {
    return await remoteDataSource.getSubmissionDetails(id);
  }

  @override
  Future<Map<String, dynamic>> updateSubmission({
    required int id,
    required String recipeName,
    required String description,
    required String categoryId,
    required int prepTime,
    required int cookTime,
    required int servings,
    required String difficulty,
    required String cuisine,
    required String foodType,
    String? notes,
    required bool allowPublication,
    required bool showAuthorName,
    String? authorDisplayName,
    String? imagePath,
    required List<Map<String, dynamic>> ingredients,
    required List<Map<String, dynamic>> steps,
    required List<String> tags,
  }) async {
    return await remoteDataSource.updateSubmission(
      id: id,
      recipeName: recipeName,
      description: description,
      categoryId: categoryId,
      prepTime: prepTime,
      cookTime: cookTime,
      servings: servings,
      difficulty: difficulty,
      cuisine: cuisine,
      foodType: foodType,
      notes: notes,
      allowPublication: allowPublication,
      showAuthorName: showAuthorName,
      authorDisplayName: authorDisplayName,
      imagePath: imagePath,
      ingredients: ingredients,
      steps: steps,
      tags: tags,
    );
  }

  @override
  Future<bool> withdrawSubmission(int id) async {
    return await remoteDataSource.withdrawSubmission(id);
  }
}
