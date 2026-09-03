import '../entities/recipe.dart';

abstract class RecipeRepository {
  Future<List<Recipe>> getAllRecipes();
  Future<Recipe?> getRecipeById(String id);
  Future<List<Recipe>> getRecipesByCategory(String categoryId);
  Future<List<Recipe>> getQuickLaunchRecipes({int maxMinutes = 25});
  Future<List<Recipe>> getFavoriteRecipes();
  Future<List<Recipe>> getCustomRecipes();
  Future<List<Recipe>> searchRecipes({
    String query = '',
    String? categoryId,
    String? difficulty,
    int? maxTimeMinutes,
  });
  Future<void> toggleFavorite(String recipeId);
  Future<void> createRecipe(Recipe recipe);
  Future<void> updateRecipe(Recipe recipe);
  Future<void> deleteRecipe(String recipeId);
  Future<List<Recipe>> syncRecipesWithServer();
}
