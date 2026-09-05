import 'package:sqflite/sqflite.dart';
import '../../../../core/database/database_service.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/localization/recipe_translations.dart';
import '../models/ingredient_model.dart';
import '../models/instruction_step_model.dart';
import '../models/recipe_model.dart';

abstract class RecipeLocalDataSource {
  Future<List<RecipeModel>> getAllRecipes();
  Future<RecipeModel?> getRecipeById(String id);
  Future<List<RecipeModel>> getRecipesByCategory(String categoryId);
  Future<List<RecipeModel>> getQuickLaunchRecipes({int maxMinutes = 25});
  Future<List<RecipeModel>> getFavoriteRecipes();
  Future<List<RecipeModel>> getCustomRecipes();
  Future<List<RecipeModel>> searchRecipes({
    String query = '',
    String? categoryId,
    String? difficulty,
    int? maxTimeMinutes,
  });
  Future<void> toggleFavorite(String recipeId);
  Future<void> createRecipe(RecipeModel recipe);
  Future<void> updateRecipe(RecipeModel recipe);
  Future<void> deleteRecipe(String recipeId);
  Future<void> upsertRecipes(List<RecipeModel> recipes);
  Future<void> syncRemoteRecipes(List<RecipeModel> remoteRecipes);
}

class RecipeLocalDataSourceImpl implements RecipeLocalDataSource {
  final DatabaseService databaseService;

  RecipeLocalDataSourceImpl(this.databaseService);

  Future<List<IngredientModel>> _getIngredients(Database db, String recipeId) async {
    final results = await db.query(
      'ingredients',
      where: 'recipe_id = ?',
      whereArgs: [recipeId],
      orderBy: 'id ASC',
    );
    return results.map((e) => IngredientModel.fromMap(e)).toList();
  }

  Future<List<InstructionStepModel>> _getInstructions(Database db, String recipeId) async {
    final results = await db.query(
      'instructions',
      where: 'recipe_id = ?',
      whereArgs: [recipeId],
      orderBy: 'step_number ASC',
    );
    return results.map((e) => InstructionStepModel.fromMap(e)).toList();
  }

  @override
  Future<List<RecipeModel>> getAllRecipes() async {
    try {
      final db = await databaseService.database;
      final results = await db.query('recipes', orderBy: 'created_at DESC');
      
      final List<RecipeModel> recipes = [];
      for (final row in results) {
        final id = row['id'] as String;
        final ingredients = await _getIngredients(db, id);
        final instructions = await _getInstructions(db, id);
        recipes.add(RecipeModel.fromMap(row, ingredients: ingredients, instructions: instructions));
      }
      return recipes;
    } catch (e) {
      throw AppDatabaseException('Failed to fetch recipes: $e');
    }
  }

  @override
  Future<RecipeModel?> getRecipeById(String id) async {
    try {
      final db = await databaseService.database;
      final results = await db.query(
        'recipes',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (results.isEmpty) return null;

      final ingredients = await _getIngredients(db, id);
      final instructions = await _getInstructions(db, id);
      return RecipeModel.fromMap(
        results.first,
        ingredients: ingredients,
        instructions: instructions,
      );
    } catch (e) {
      throw AppDatabaseException('Failed to fetch recipe by ID: $e');
    }
  }

  @override
  Future<List<RecipeModel>> getRecipesByCategory(String categoryId) async {
    try {
      final db = await databaseService.database;
      final results = await db.query(
        'recipes',
        where: 'category_id = ?',
        whereArgs: [categoryId],
        orderBy: 'title ASC',
      );

      final List<RecipeModel> recipes = [];
      for (final row in results) {
        final id = row['id'] as String;
        final ingredients = await _getIngredients(db, id);
        final instructions = await _getInstructions(db, id);
        recipes.add(RecipeModel.fromMap(row, ingredients: ingredients, instructions: instructions));
      }
      return recipes;
    } catch (e) {
      throw AppDatabaseException('Failed to fetch recipes by category: $e');
    }
  }

  @override
  Future<List<RecipeModel>> getQuickLaunchRecipes({int maxMinutes = 25}) async {
    try {
      final db = await databaseService.database;
      final results = await db.query(
        'recipes',
        where: '(prep_time_minutes + cook_time_minutes) <= ?',
        whereArgs: [maxMinutes],
        orderBy: '(prep_time_minutes + cook_time_minutes) ASC',
      );

      final List<RecipeModel> recipes = [];
      for (final row in results) {
        final id = row['id'] as String;
        final ingredients = await _getIngredients(db, id);
        final instructions = await _getInstructions(db, id);
        recipes.add(RecipeModel.fromMap(row, ingredients: ingredients, instructions: instructions));
      }
      return recipes;
    } catch (e) {
      throw AppDatabaseException('Failed to fetch quick launch recipes: $e');
    }
  }

  @override
  Future<List<RecipeModel>> getFavoriteRecipes() async {
    try {
      final db = await databaseService.database;
      final results = await db.query(
        'recipes',
        where: 'is_favorite = 1',
        orderBy: 'created_at DESC',
      );

      final List<RecipeModel> recipes = [];
      for (final row in results) {
        final id = row['id'] as String;
        final ingredients = await _getIngredients(db, id);
        final instructions = await _getInstructions(db, id);
        recipes.add(RecipeModel.fromMap(row, ingredients: ingredients, instructions: instructions));
      }
      return recipes;
    } catch (e) {
      throw AppDatabaseException('Failed to fetch favorite recipes: $e');
    }
  }

  @override
  Future<List<RecipeModel>> getCustomRecipes() async {
    try {
      final db = await databaseService.database;
      final results = await db.query(
        'recipes',
        where: 'is_custom = 1',
        orderBy: 'created_at DESC',
      );

      final List<RecipeModel> recipes = [];
      for (final row in results) {
        final id = row['id'] as String;
        final ingredients = await _getIngredients(db, id);
        final instructions = await _getInstructions(db, id);
        recipes.add(RecipeModel.fromMap(row, ingredients: ingredients, instructions: instructions));
      }
      return recipes;
    } catch (e) {
      throw AppDatabaseException('Failed to fetch custom recipes: $e');
    }
  }

  @override
  Future<List<RecipeModel>> searchRecipes({
    String query = '',
    String? categoryId,
    String? difficulty,
    int? maxTimeMinutes,
  }) async {
    try {
      final db = await databaseService.database;
      final cleanQuery = query.trim().toLowerCase();
      final isHashtag = cleanQuery.startsWith('#');
      final tagKeyword = isHashtag ? cleanQuery.replaceFirst(RegExp(r'^#+'), '') : cleanQuery;

      final List<String> whereClauses = [];
      final List<dynamic> whereArgs = [];

      if (cleanQuery.isNotEmpty) {
        if (isHashtag) {
          whereClauses.add('(LOWER(r.tags) LIKE ? OR LOWER(r.title) LIKE ?)');
          final pattern = '%$tagKeyword%';
          whereArgs.addAll([pattern, pattern]);
        } else {
          whereClauses.add('''
            (
              LOWER(r.title) LIKE ? OR
              LOWER(r.description) LIKE ? OR
              LOWER(r.chef_name) LIKE ? OR
              LOWER(r.cuisine) LIKE ? OR
              LOWER(r.region) LIKE ? OR
              LOWER(r.subcategory) LIKE ? OR
              LOWER(r.tags) LIKE ? OR
              EXISTS (
                SELECT 1 FROM ingredients i 
                WHERE i.recipe_id = r.id AND LOWER(i.name) LIKE ?
              )
            )
          ''');
          final pattern = '%$cleanQuery%';
          whereArgs.addAll([pattern, pattern, pattern, pattern, pattern, pattern, pattern, pattern]);
        }
      }

      if (categoryId != null && categoryId.isNotEmpty && categoryId != 'all') {
        whereClauses.add('r.category_id = ?');
        whereArgs.add(categoryId);
      }

      if (difficulty != null && difficulty.isNotEmpty && difficulty != 'all') {
        whereClauses.add('LOWER(r.difficulty) = ?');
        whereArgs.add(difficulty.toLowerCase());
      }

      if (maxTimeMinutes != null && maxTimeMinutes > 0) {
        whereClauses.add('(r.prep_time_minutes + r.cook_time_minutes) <= ?');
        whereArgs.add(maxTimeMinutes);
      }

      final whereString = whereClauses.isNotEmpty ? 'WHERE ${whereClauses.join(' AND ')}' : '';

      final results = await db.rawQuery('''
        SELECT r.* FROM recipes r
        $whereString
        ORDER BY r.is_favorite DESC, r.title ASC
      ''', whereArgs);

      final List<RecipeModel> recipes = [];
      for (final row in results) {
        final id = row['id'] as String;
        final ingredients = await _getIngredients(db, id);
        final instructions = await _getInstructions(db, id);
        recipes.add(RecipeModel.fromMap(row, ingredients: ingredients, instructions: instructions));
      }

      if (cleanQuery.isNotEmpty && recipes.isEmpty) {
        final allCandidates = await getAllRecipes();
        final matched = allCandidates.where((r) {
          if (categoryId != null && categoryId.isNotEmpty && categoryId != 'all' && r.categoryId != categoryId) return false;
          if (difficulty != null && difficulty.isNotEmpty && difficulty != 'all' && r.difficulty.name.toLowerCase() != difficulty.toLowerCase()) return false;
          if (maxTimeMinutes != null && maxTimeMinutes > 0 && r.totalTimeMinutes > maxTimeMinutes) return false;
          return RecipeTranslations.matchesQuery(r, cleanQuery);
        }).toList();
        return matched;
      }

      return recipes;
    } catch (e) {
      throw AppDatabaseException('Failed to search recipes: $e');
    }
  }

  @override
  Future<void> toggleFavorite(String recipeId) async {
    try {
      final db = await databaseService.database;
      await db.rawUpdate('''
        UPDATE recipes
        SET is_favorite = CASE WHEN is_favorite = 1 THEN 0 ELSE 1 END
        WHERE id = ?
      ''', [recipeId]);
    } catch (e) {
      throw AppDatabaseException('Failed to toggle favorite: $e');
    }
  }

  @override
  Future<void> createRecipe(RecipeModel recipe) async {
    try {
      final db = await databaseService.database;
      await db.transaction((txn) async {
        await txn.insert('recipes', recipe.toMap());

        for (final ing in recipe.ingredients) {
          final ingModel = IngredientModel(
            name: ing.name,
            amount: ing.amount,
            unit: ing.unit,
          );
          await txn.insert('ingredients', ingModel.toMap(recipe.id));
        }

        for (final inst in recipe.instructions) {
          final instModel = InstructionStepModel(
            stepNumber: inst.stepNumber,
            instruction: inst.instruction,
            timerSeconds: inst.timerSeconds,
          );
          await txn.insert('instructions', instModel.toMap(recipe.id));
        }
      });
    } catch (e) {
      throw AppDatabaseException('Failed to create recipe: $e');
    }
  }

  @override
  Future<void> updateRecipe(RecipeModel recipe) async {
    try {
      final db = await databaseService.database;
      await db.transaction((txn) async {
        await txn.update(
          'recipes',
          recipe.toMap(),
          where: 'id = ?',
          whereArgs: [recipe.id],
        );

        // Replace ingredients
        await txn.delete('ingredients', where: 'recipe_id = ?', whereArgs: [recipe.id]);
        for (final ing in recipe.ingredients) {
          final ingModel = IngredientModel(
            name: ing.name,
            amount: ing.amount,
            unit: ing.unit,
          );
          await txn.insert('ingredients', ingModel.toMap(recipe.id));
        }

        // Replace instructions
        await txn.delete('instructions', where: 'recipe_id = ?', whereArgs: [recipe.id]);
        for (final inst in recipe.instructions) {
          final instModel = InstructionStepModel(
            stepNumber: inst.stepNumber,
            instruction: inst.instruction,
            timerSeconds: inst.timerSeconds,
          );
          await txn.insert('instructions', instModel.toMap(recipe.id));
        }
      });
    } catch (e) {
      throw AppDatabaseException('Failed to update recipe: $e');
    }
  }

  @override
  Future<void> deleteRecipe(String recipeId) async {
    try {
      final db = await databaseService.database;
      await db.transaction((txn) async {
        await txn.delete('instructions', where: 'recipe_id = ?', whereArgs: [recipeId]);
        await txn.delete('ingredients', where: 'recipe_id = ?', whereArgs: [recipeId]);
        await txn.delete('recipes', where: 'id = ?', whereArgs: [recipeId]);
      });
    } catch (e) {
      throw AppDatabaseException('Failed to delete recipe: $e');
    }
  }

  @override
  Future<void> upsertRecipes(List<RecipeModel> recipes) async {
    if (recipes.isEmpty) return;
    try {
      final db = await databaseService.database;
      await db.transaction((txn) async {
        for (final recipe in recipes) {
          // Check existing local favorite/custom status to preserve it
          final existing = await txn.query(
            'recipes',
            columns: ['is_favorite', 'is_custom'],
            where: 'id = ?',
            whereArgs: [recipe.id],
            limit: 1,
          );

          int isFav = recipe.isFavorite ? 1 : 0;
          int isCustom = recipe.isCustom ? 1 : 0;

          if (existing.isNotEmpty) {
            // Preserve user's local favorite and custom status
            final localFav = existing.first['is_favorite'];
            if (localFav != null) {
              isFav = (localFav as num) == 1 ? 1 : isFav;
            }
            final localCustom = existing.first['is_custom'];
            if (localCustom != null) {
              isCustom = (localCustom as num) == 1 ? 1 : isCustom;
            }
          }

          final recipeMap = recipe.toMap();
          recipeMap['is_favorite'] = isFav;
          recipeMap['is_custom'] = isCustom;

          await txn.insert(
            'recipes',
            recipeMap,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );

          // Replace ingredients
          await txn.delete('ingredients', where: 'recipe_id = ?', whereArgs: [recipe.id]);
          for (final ing in recipe.ingredients) {
            final ingModel = IngredientModel(
              name: ing.name,
              amount: ing.amount,
              unit: ing.unit,
            );
            await txn.insert('ingredients', ingModel.toMap(recipe.id));
          }

          // Replace instructions
          await txn.delete('instructions', where: 'recipe_id = ?', whereArgs: [recipe.id]);
          for (final inst in recipe.instructions) {
            final instModel = InstructionStepModel(
              stepNumber: inst.stepNumber,
              instruction: inst.instruction,
              timerSeconds: inst.timerSeconds,
            );
            await txn.insert('instructions', instModel.toMap(recipe.id));
          }
        }
      });
    } catch (e) {
      throw AppDatabaseException('Failed to batch upsert recipes: $e');
    }
  }

  @override
  Future<void> syncRemoteRecipes(List<RecipeModel> remoteRecipes) async {
    if (remoteRecipes.isEmpty) return;
    try {
      final db = await databaseService.database;
      await db.transaction((txn) async {
        // 1. Batch upsert incoming remote recipes
        for (final recipe in remoteRecipes) {
          final existing = await txn.query(
            'recipes',
            columns: ['is_favorite', 'is_custom'],
            where: 'id = ?',
            whereArgs: [recipe.id],
            limit: 1,
          );

          int isFav = recipe.isFavorite ? 1 : 0;
          int isCustom = recipe.isCustom ? 1 : 0;

          if (existing.isNotEmpty) {
            final localFav = existing.first['is_favorite'];
            if (localFav != null) {
              isFav = (localFav as num) == 1 ? 1 : isFav;
            }
            final localCustom = existing.first['is_custom'];
            if (localCustom != null) {
              isCustom = (localCustom as num) == 1 ? 1 : isCustom;
            }
          }

          final recipeMap = recipe.toMap();
          recipeMap['is_favorite'] = isFav;
          recipeMap['is_custom'] = isCustom;

          await txn.insert(
            'recipes',
            recipeMap,
            conflictAlgorithm: ConflictAlgorithm.replace,
          );

          // Replace ingredients
          await txn.delete('ingredients', where: 'recipe_id = ?', whereArgs: [recipe.id]);
          for (final ing in recipe.ingredients) {
            final ingModel = IngredientModel(
              name: ing.name,
              amount: ing.amount,
              unit: ing.unit,
            );
            await txn.insert('ingredients', ingModel.toMap(recipe.id));
          }

          // Replace instructions
          await txn.delete('instructions', where: 'recipe_id = ?', whereArgs: [recipe.id]);
          for (final inst in recipe.instructions) {
            final instModel = InstructionStepModel(
              stepNumber: inst.stepNumber,
              instruction: inst.instruction,
              timerSeconds: inst.timerSeconds,
            );
            await txn.insert('instructions', instModel.toMap(recipe.id));
          }
        }

        // 2. Prune obsolete server recipes (recipes deleted on admin panel)
        final serverIds = remoteRecipes.map((r) => r.id).toList();
        final placeholders = List.filled(serverIds.length, '?').join(',');
        final deletedRows = await txn.rawQuery(
          'SELECT id FROM recipes WHERE is_custom = 0 AND id NOT IN ($placeholders)',
          serverIds,
        );
        for (final row in deletedRows) {
          final delId = row['id'] as String;
          await txn.delete('instructions', where: 'recipe_id = ?', whereArgs: [delId]);
          await txn.delete('ingredients', where: 'recipe_id = ?', whereArgs: [delId]);
          await txn.delete('recipes', where: 'id = ?', whereArgs: [delId]);
        }
      });
    } catch (e) {
      throw AppDatabaseException('Failed to sync remote recipes: $e');
    }
  }
}
