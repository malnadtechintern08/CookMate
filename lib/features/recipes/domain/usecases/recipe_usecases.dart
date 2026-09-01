import '../entities/recipe.dart';
import '../repositories/recipe_repository.dart';

class GetAllRecipesUseCase {
  final RecipeRepository repository;
  const GetAllRecipesUseCase(this.repository);

  Future<List<Recipe>> execute() async {
    return await repository.getAllRecipes();
  }
}

class GetRecipeByIdUseCase {
  final RecipeRepository repository;
  const GetRecipeByIdUseCase(this.repository);

  Future<Recipe?> execute(String id) async {
    return await repository.getRecipeById(id);
  }
}

class GetRecipesByCategoryUseCase {
  final RecipeRepository repository;
  const GetRecipesByCategoryUseCase(this.repository);

  Future<List<Recipe>> execute(String categoryId) async {
    return await repository.getRecipesByCategory(categoryId);
  }
}

class GetQuickLaunchRecipesUseCase {
  final RecipeRepository repository;
  const GetQuickLaunchRecipesUseCase(this.repository);

  Future<List<Recipe>> execute({int maxMinutes = 25}) async {
    return await repository.getQuickLaunchRecipes(maxMinutes: maxMinutes);
  }
}

class GetFavoriteRecipesUseCase {
  final RecipeRepository repository;
  const GetFavoriteRecipesUseCase(this.repository);

  Future<List<Recipe>> execute() async {
    return await repository.getFavoriteRecipes();
  }
}

class GetCustomRecipesUseCase {
  final RecipeRepository repository;
  const GetCustomRecipesUseCase(this.repository);

  Future<List<Recipe>> execute() async {
    return await repository.getCustomRecipes();
  }
}

class SearchRecipesUseCase {
  final RecipeRepository repository;
  const SearchRecipesUseCase(this.repository);

  Future<List<Recipe>> execute({
    String query = '',
    String? categoryId,
    String? difficulty,
    int? maxTimeMinutes,
  }) async {
    return await repository.searchRecipes(
      query: query,
      categoryId: categoryId,
      difficulty: difficulty,
      maxTimeMinutes: maxTimeMinutes,
    );
  }
}

class ToggleFavoriteUseCase {
  final RecipeRepository repository;
  const ToggleFavoriteUseCase(this.repository);

  Future<void> execute(String recipeId) async {
    await repository.toggleFavorite(recipeId);
  }
}

class CreateRecipeUseCase {
  final RecipeRepository repository;
  const CreateRecipeUseCase(this.repository);

  Future<void> execute(Recipe recipe) async {
    await repository.createRecipe(recipe);
  }
}

class UpdateRecipeUseCase {
  final RecipeRepository repository;
  const UpdateRecipeUseCase(this.repository);

  Future<void> execute(Recipe recipe) async {
    await repository.updateRecipe(recipe);
  }
}

class DeleteRecipeUseCase {
  final RecipeRepository repository;
  const DeleteRecipeUseCase(this.repository);

  Future<void> execute(String recipeId) async {
    await repository.deleteRecipe(recipeId);
  }
}
