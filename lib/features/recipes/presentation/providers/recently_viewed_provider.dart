import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/recipe.dart';
import 'recipe_providers.dart';

final recentlyViewedIdsProvider = StateNotifierProvider<RecentlyViewedNotifier, List<String>>((ref) {
  return RecentlyViewedNotifier();
});

class RecentlyViewedNotifier extends StateNotifier<List<String>> {
  RecentlyViewedNotifier() : super([]) {
    _loadIds();
  }

  Future<void> _loadIds() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final ids = prefs.getStringList(AppConstants.keyRecentlyViewed) ?? [];
      state = ids;
    } catch (_) {}
  }

  Future<void> recordView(String recipeId) async {
    final current = List<String>.from(state);
    current.remove(recipeId);
    current.insert(0, recipeId);
    if (current.length > AppConstants.maxRecentlyViewed) {
      current.removeLast();
    }
    state = current;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(AppConstants.keyRecentlyViewed, current);
    } catch (_) {}
  }

  Future<void> clearHistory() async {
    state = [];
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.keyRecentlyViewed);
    } catch (_) {}
  }
}

final recentlyViewedRecipesProvider = FutureProvider<List<Recipe>>((ref) async {
  final ids = ref.watch(recentlyViewedIdsProvider);
  if (ids.isEmpty) return [];

  final allRecipes = await ref.watch(allRecipesProvider.future);
  final recipeMap = {for (var r in allRecipes) r.id: r};

  final List<Recipe> result = [];
  for (final id in ids) {
    if (recipeMap.containsKey(id)) {
      result.add(recipeMap[id]!);
    }
  }
  return result;
});
