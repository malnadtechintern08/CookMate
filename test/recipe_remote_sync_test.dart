import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:cookmate/features/recipes/data/datasources/recipe_local_datasource.dart';
import 'package:cookmate/features/recipes/data/datasources/recipe_remote_datasource.dart';
import 'package:cookmate/features/recipes/data/models/recipe_model.dart';
import 'package:cookmate/features/recipes/data/repositories/recipe_repository_impl.dart';
import 'package:cookmate/features/recipes/domain/entities/recipe.dart';

class MockLocalDataSource implements RecipeLocalDataSource {
  List<RecipeModel> localRecipes = [];

  @override
  Future<List<RecipeModel>> getAllRecipes() async => localRecipes;

  @override
  Future<RecipeModel?> getRecipeById(String id) async {
    try {
      return localRecipes.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> upsertRecipes(List<RecipeModel> recipes) async {
    for (final r in recipes) {
      localRecipes.removeWhere((item) => item.id == r.id);
      localRecipes.add(r);
    }
  }

  @override
  Future<List<RecipeModel>> getRecipesByCategory(String categoryId) async =>
      localRecipes.where((r) => r.categoryId == categoryId).toList();

  @override
  Future<List<RecipeModel>> getQuickLaunchRecipes({int maxMinutes = 25}) async =>
      localRecipes.where((r) => r.totalTimeMinutes <= maxMinutes).toList();

  @override
  Future<List<RecipeModel>> getFavoriteRecipes() async =>
      localRecipes.where((r) => r.isFavorite).toList();

  @override
  Future<List<RecipeModel>> getCustomRecipes() async =>
      localRecipes.where((r) => r.isCustom).toList();

  @override
  Future<List<RecipeModel>> searchRecipes({
    String query = '',
    String? categoryId,
    String? difficulty,
    int? maxTimeMinutes,
  }) async =>
      localRecipes.where((r) => r.title.contains(query)).toList();

  @override
  Future<void> toggleFavorite(String recipeId) async {}

  @override
  Future<void> createRecipe(RecipeModel recipe) async {
    localRecipes.add(recipe);
  }

  @override
  Future<void> updateRecipe(RecipeModel recipe) async {
    final idx = localRecipes.indexWhere((r) => r.id == recipe.id);
    if (idx != -1) localRecipes[idx] = recipe;
  }

  @override
  Future<void> deleteRecipe(String recipeId) async {
    localRecipes.removeWhere((r) => r.id == recipeId);
  }

  @override
  Future<void> syncRemoteRecipes(List<RecipeModel> remoteRecipes) async {
    final custom = localRecipes.where((r) => r.isCustom).toList();
    localRecipes = [...custom, ...remoteRecipes];
  }
}

void main() {
  group('RecipeRemoteDataSource & Live Sync Tests', () {
    test('RecipeRemoteDataSource parses server JSON payload correctly', () async {
      final mockResponseData = {
        'status': 'success',
        'count': 1,
        'data': [
          {
            'id': 'recipe_server_1',
            'title': 'Server Mango Lassi',
            'description': 'Fresh yogurt smoothie with mango pulp.',
            'chef_name': 'Chef Sanjeev',
            'cuisine': 'Indian',
            'image_url': 'uploads/recipe_mango.jpg',
            'prep_time_minutes': '10',
            'cook_time_minutes': '5',
            'servings': '2',
            'difficulty': 'Easy',
            'category_id': 'cat_drinks',
            'tags': 'Summer,Cold,Sweet',
            'is_favorite': '0',
            'is_custom': '0',
            'is_vegetarian': '1',
            'rating': '4.9',
            'region': 'North India',
            'subcategory': 'Smoothies',
            'nutrition': '210 kcal | 5g Protein | 32g Carbs',
            'created_at': '2026-09-02 12:00:00',
            'ingredients': [
              {
                'name': 'Mango Pulp',
                'amount': '1.5',
                'unit': 'cups',
                'notes': 'Alphonso'
              }
            ],
            'instructions': [
              {
                'step_number': '1',
                'instruction': 'Blend yogurt and mango pulp.',
                'timer_seconds': '60',
                'tip': 'Serve chilled'
              }
            ]
          }
        ]
      };

      final mockClient = MockClient((request) async {
        expect(request.url.path, contains('/api/recipes.php'));
        return http.Response(
          json.encode(mockResponseData),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      });

      final remoteDataSource = RecipeRemoteDataSourceImpl(client: mockClient);
      final recipes = await remoteDataSource.fetchRecipes(limit: 10);

      expect(recipes.length, 1);
      final recipe = recipes.first;
      expect(recipe.id, 'recipe_server_1');
      expect(recipe.title, 'Server Mango Lassi');
      expect(recipe.rating, 4.9);
      expect(recipe.prepTimeMinutes, 10);
      expect(recipe.isVegetarian, true);
      expect(recipe.ingredients.length, 1);
      expect(recipe.ingredients.first.amount, 1.5);
      expect(recipe.instructions.length, 1);
      expect(recipe.instructions.first.stepNumber, 1);
      expect(recipe.instructions.first.timerSeconds, 60);
    });

    test('RecipeRepositoryImpl syncs remote recipes into local database', () async {
      final mockLocal = MockLocalDataSource();
      final mockClient = MockClient((request) async {
        return http.Response(
          json.encode({
            'status': 'success',
            'count': 1,
            'data': [
              {
                'id': 'recipe_remote_99',
                'title': 'Remote Special Curry',
                'description': 'Authentic taste.',
                'chef_name': 'Chef CookMate',
                'cuisine': 'Indian',
                'image_url': 'assets/images/recipes/curry.jpg',
                'prep_time_minutes': 15,
                'cook_time_minutes': 20,
                'servings': 4,
                'difficulty': 'Medium',
                'category_id': 'cat_curry',
                'tags': 'Curry,Spicy',
                'is_favorite': 0,
                'is_custom': 0,
                'is_vegetarian': 1,
                'rating': 4.8,
                'created_at': '2026-09-02 12:00:00',
              }
            ]
          }),
          200,
        );
      });

      final remoteDataSource = RecipeRemoteDataSourceImpl(client: mockClient);
      final repository = RecipeRepositoryImpl(mockLocal, remoteDataSource);

      expect(mockLocal.localRecipes, isEmpty);

      // Perform sync
      final synced = await repository.syncRecipesWithServer();

      expect(synced.length, 1);
      expect(mockLocal.localRecipes.length, 1);
      expect(mockLocal.localRecipes.first.id, 'recipe_remote_99');
      expect(mockLocal.localRecipes.first.title, 'Remote Special Curry');
    });

    test('RecipeRepositoryImpl handles server network errors gracefully without crashing', () async {
      final mockLocal = MockLocalDataSource();
      mockLocal.localRecipes.add(
        RecipeModel(
          id: 'local_cached_1',
          title: 'Cached Local Dosa',
          description: 'Local item',
          chefName: 'Chef',
          cuisine: 'South Indian',
          imageUrl: '',
          prepTimeMinutes: 10,
          cookTimeMinutes: 5,
          servings: 2,
          difficulty: RecipeDifficulty.easy,
          categoryId: 'cat_breakfast',
          tags: const ['Dosa'],
          createdAt: DateTime.now(),
        ),
      );

      // Client that simulates 500 server error
      final mockClient = MockClient((request) async {
        return http.Response('Internal Server Error', 500);
      });

      final remoteDataSource = RecipeRemoteDataSourceImpl(client: mockClient);
      final repository = RecipeRepositoryImpl(mockLocal, remoteDataSource);

      // Sync should not crash; it should catch the error and return existing local cache
      final results = await repository.syncRecipesWithServer();
      expect(results.length, 1);
      expect(results.first.title, 'Cached Local Dosa');
    });
  });
}
