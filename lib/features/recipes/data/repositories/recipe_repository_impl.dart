import '../../domain/entities/recipe.dart';
import '../../domain/repositories/recipe_repository.dart';
import '../datasources/recipe_local_datasource.dart';
import '../models/ingredient_model.dart';
import '../models/instruction_step_model.dart';
import '../models/recipe_model.dart';

class RecipeRepositoryImpl implements RecipeRepository {
  final RecipeLocalDataSource localDataSource;

  RecipeRepositoryImpl(this.localDataSource);

  RecipeModel _toModel(Recipe recipe) {
    return RecipeModel(
      id: recipe.id,
      title: recipe.title,
      description: recipe.description,
      chefName: recipe.chefName,
      cuisine: recipe.cuisine,
      imageUrl: recipe.imageUrl,
      prepTimeMinutes: recipe.prepTimeMinutes,
      cookTimeMinutes: recipe.cookTimeMinutes,
      servings: recipe.servings,
      difficulty: recipe.difficulty,
      categoryId: recipe.categoryId,
      tags: recipe.tags,
      isFavorite: recipe.isFavorite,
      isCustom: recipe.isCustom,
      createdAt: recipe.createdAt,
      ingredients: recipe.ingredients
          .map((i) => IngredientModel(id: i.id, name: i.name, amount: i.amount, unit: i.unit))
          .toList(),
      instructions: recipe.instructions
          .map((s) => InstructionStepModel(
                id: s.id,
                stepNumber: s.stepNumber,
                instruction: s.instruction,
                timerSeconds: s.timerSeconds,
              ))
          .toList(),
    );
  }

  @override
  Future<List<Recipe>> getAllRecipes() async {
    return await localDataSource.getAllRecipes();
  }

  @override
  Future<Recipe?> getRecipeById(String id) async {
    return await localDataSource.getRecipeById(id);
  }

  @override
  Future<List<Recipe>> getRecipesByCategory(String categoryId) async {
    return await localDataSource.getRecipesByCategory(categoryId);
  }

  @override
  Future<List<Recipe>> getQuickLaunchRecipes({int maxMinutes = 25}) async {
    return await localDataSource.getQuickLaunchRecipes(maxMinutes: maxMinutes);
  }

  @override
  Future<List<Recipe>> getFavoriteRecipes() async {
    return await localDataSource.getFavoriteRecipes();
  }

  @override
  Future<List<Recipe>> getCustomRecipes() async {
    return await localDataSource.getCustomRecipes();
  }

  @override
  Future<List<Recipe>> searchRecipes({
    String query = '',
    String? categoryId,
    String? difficulty,
    int? maxTimeMinutes,
  }) async {
    return await localDataSource.searchRecipes(
      query: query,
      categoryId: categoryId,
      difficulty: difficulty,
      maxTimeMinutes: maxTimeMinutes,
    );
  }

  @override
  Future<void> toggleFavorite(String recipeId) async {
    await localDataSource.toggleFavorite(recipeId);
  }

  @override
  Future<void> createRecipe(Recipe recipe) async {
    await localDataSource.createRecipe(_toModel(recipe));
  }

  @override
  Future<void> updateRecipe(Recipe recipe) async {
    await localDataSource.updateRecipe(_toModel(recipe));
  }

  @override
  Future<void> deleteRecipe(String recipeId) async {
    await localDataSource.deleteRecipe(recipeId);
  }
}
