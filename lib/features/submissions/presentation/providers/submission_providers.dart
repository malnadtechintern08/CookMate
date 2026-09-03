import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/submission_remote_datasource.dart';
import '../../data/repositories/submission_repository_impl.dart';
import '../../domain/entities/recipe_submission.dart';

// Data Source Provider
final submissionRemoteDataSourceProvider =
    Provider<SubmissionRemoteDataSource>((ref) {
  return SubmissionRemoteDataSourceImpl();
});

// Repository Provider
final submissionRepositoryProvider = Provider<SubmissionRepository>((ref) {
  final remote = ref.watch(submissionRemoteDataSourceProvider);
  return SubmissionRepositoryImpl(remote);
});

// User Submissions List Provider
final mySubmissionsProvider =
    FutureProvider.autoDispose<List<RecipeSubmission>>((ref) async {
  final repo = ref.watch(submissionRepositoryProvider);
  return await repo.getMySubmissions();
});

// Single Submission Detail Provider
final submissionDetailsProvider =
    FutureProvider.autoDispose.family<RecipeSubmission, int>((ref, id) async {
  final repo = ref.watch(submissionRepositoryProvider);
  return await repo.getSubmissionDetails(id);
});

// Submission Controller Provider
final submissionControllerProvider =
    StateNotifierProvider<SubmissionController, AsyncValue<Map<String, dynamic>?>>(
  (ref) => SubmissionController(ref.watch(submissionRepositoryProvider), ref),
);

class SubmissionController extends StateNotifier<AsyncValue<Map<String, dynamic>?>> {
  final SubmissionRepository _repository;
  final Ref _ref;

  SubmissionController(this._repository, this._ref)
      : super(const AsyncValue.data(null));

  Future<bool> submitRecipe({
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
    state = const AsyncValue.loading();
    try {
      final res = await _repository.submitRecipe(
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

      state = AsyncValue.data(res);
      // Invalidate list so it refreshes immediately
      _ref.invalidate(mySubmissionsProvider);
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> updateSubmission({
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
    state = const AsyncValue.loading();
    try {
      final res = await _repository.updateSubmission(
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

      state = AsyncValue.data(res);
      _ref.invalidate(mySubmissionsProvider);
      _ref.invalidate(submissionDetailsProvider(id));
      return true;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return false;
    }
  }

  Future<bool> withdrawSubmission(int id) async {
    try {
      final success = await _repository.withdrawSubmission(id);
      if (success) {
        _ref.invalidate(mySubmissionsProvider);
      }
      return success;
    } catch (_) {
      return false;
    }
  }
}
