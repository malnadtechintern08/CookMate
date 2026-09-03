import 'package:flutter_test/flutter_test.dart';
import 'package:cookmate/features/recipes/domain/entities/recipe.dart';
import 'package:cookmate/features/recipes/domain/repositories/recipe_repository.dart';
import 'package:cookmate/features/recipes/domain/usecases/recipe_usecases.dart';

class MockRecipeRepository implements RecipeRepository {
  final List<Recipe> _recipes = [
    Recipe(
      id: 'rec_1',
      title: 'Spaghetti Carbonara',
      description: 'Roman pasta',
      chefName: 'Massimo Bottura',
      cuisine: 'Italian',
      imageUrl: 'https://example.com/carbonara.jpg',
      prepTimeMinutes: 10,
      cookTimeMinutes: 12,
      servings: 2,
      difficulty: RecipeDifficulty.medium,
      categoryId: 'cat_italian',
      tags: const ['Italian', 'Pasta'],
      isFavorite: true,
      createdAt: DateTime.now(),
    ),
    Recipe(
      id: 'rec_2',
      title: 'Butter Chicken',
      description: 'Delhi style',
      chefName: 'Vikas Khanna',
      cuisine: 'Indian',
      imageUrl: 'https://example.com/chicken.jpg',
      prepTimeMinutes: 20,
      cookTimeMinutes: 25,
      servings: 4,
      difficulty: RecipeDifficulty.medium,
      categoryId: 'cat_indian',
      tags: const ['Indian', 'Curry'],
      isFavorite: false,
      createdAt: DateTime.now(),
    ),
  ];

  @override
  Future<List<Recipe>> getAllRecipes() async => _recipes;

  @override
  Future<Recipe?> getRecipeById(String id) async {
    try {
      return _recipes.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Recipe>> getRecipesByCategory(String categoryId) async {
    return _recipes.where((r) => r.categoryId == categoryId).toList();
  }

  @override
  Future<List<Recipe>> getQuickLaunchRecipes({int maxMinutes = 25}) async {
    return _recipes.where((r) => r.totalTimeMinutes <= maxMinutes).toList();
  }

  @override
  Future<List<Recipe>> getFavoriteRecipes() async {
    return _recipes.where((r) => r.isFavorite).toList();
  }

  @override
  Future<List<Recipe>> getCustomRecipes() async {
    return _recipes.where((r) => r.isCustom).toList();
  }

  @override
  Future<List<Recipe>> searchRecipes({
    String query = '',
    String? categoryId,
    String? difficulty,
    int? maxTimeMinutes,
  }) async {
    return _recipes.where((r) => r.title.toLowerCase().contains(query.toLowerCase())).toList();
  }

  @override
  Future<void> toggleFavorite(String recipeId) async {
    final idx = _recipes.indexWhere((r) => r.id == recipeId);
    if (idx != -1) {
      _recipes[idx] = _recipes[idx].copyWith(isFavorite: !_recipes[idx].isFavorite);
    }
  }

  @override
  Future<void> createRecipe(Recipe recipe) async {
    _recipes.add(recipe);
  }

  @override
  Future<void> updateRecipe(Recipe recipe) async {
    final idx = _recipes.indexWhere((r) => r.id == recipe.id);
    if (idx != -1) {
      _recipes[idx] = recipe;
    }
  }

  @override
  Future<void> deleteRecipe(String recipeId) async {
    _recipes.removeWhere((r) => r.id == recipeId);
  }

  @override
  Future<List<Recipe>> syncRecipesWithServer() async => _recipes;
}

void main() {
  group('Recipe Use Cases Unit Tests', () {
    late MockRecipeRepository repository;
    late GetAllRecipesUseCase getAllRecipesUseCase;
    late GetQuickLaunchRecipesUseCase getQuickLaunchUseCase;
    late GetFavoriteRecipesUseCase getFavoriteRecipesUseCase;
    late ToggleFavoriteUseCase toggleFavoriteUseCase;

    setUp(() {
      repository = MockRecipeRepository();
      getAllRecipesUseCase = GetAllRecipesUseCase(repository);
      getQuickLaunchUseCase = GetQuickLaunchRecipesUseCase(repository);
      getFavoriteRecipesUseCase = GetFavoriteRecipesUseCase(repository);
      toggleFavoriteUseCase = ToggleFavoriteUseCase(repository);
    });

    test('GetAllRecipesUseCase returns all recipes', () async {
      final recipes = await getAllRecipesUseCase.execute();
      expect(recipes.length, equals(2));
    });

    test('GetQuickLaunchRecipesUseCase filters recipes under max time', () async {
      final quick = await getQuickLaunchUseCase.execute(maxMinutes: 25);
      // Spaghetti Carbonara is 10+12 = 22 mins (< 25)
      expect(quick.length, equals(1));
      expect(quick.first.title, equals('Spaghetti Carbonara'));
    });

    test('GetFavoriteRecipesUseCase and ToggleFavoriteUseCase work seamlessly', () async {
      var favs = await getFavoriteRecipesUseCase.execute();
      expect(favs.length, equals(1));
      expect(favs.first.id, equals('rec_1'));

      // Toggle off
      await toggleFavoriteUseCase.execute('rec_1');
      favs = await getFavoriteRecipesUseCase.execute();
      expect(favs.length, equals(0));

      // Toggle back on
      await toggleFavoriteUseCase.execute('rec_1');
      favs = await getFavoriteRecipesUseCase.execute();
      expect(favs.length, equals(1));
    });
  });
}
