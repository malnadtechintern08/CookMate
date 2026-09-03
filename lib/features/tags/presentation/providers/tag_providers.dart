import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../data/datasources/tag_remote_datasource.dart';
import '../../data/repositories/tag_repository_impl.dart';
import '../../domain/entities/tag.dart';

final tagRemoteDataSourceProvider = Provider<TagRemoteDataSource>((ref) {
  return TagRemoteDataSourceImpl();
});

final tagRepositoryProvider = Provider<TagRepository>((ref) {
  final remote = ref.watch(tagRemoteDataSourceProvider);
  return TagRepositoryImpl(remote);
});

/// Fetches top popular/trending hashtags from MySQL
final popularTagsProvider = FutureProvider<List<Tag>>((ref) async {
  final repo = ref.watch(tagRepositoryProvider);
  return await repo.getPopularTags(limit: 15);
});

/// Autocomplete suggestions when user types '#' or '#ri'
final tagSuggestionsProvider = FutureProvider.family<List<Tag>, String>((ref, query) async {
  final clean = query.trim().replaceFirst(RegExp(r'^#+'), '');
  final repo = ref.watch(tagRepositoryProvider);
  return await repo.searchTags(clean, limit: 10);
});

/// Fetches recipes tagged with a specific hashtag
final hashtagRecipesProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, tag) async {
  final clean = tag.trim().replaceFirst(RegExp(r'^#+'), '');
  final repo = ref.watch(tagRepositoryProvider);
  return await repo.getRecipesByTag(tag: clean, page: 1, limit: 50);
});

/// Manages recent search queries with SharedPreferences persistence
class RecentSearchesNotifier extends StateNotifier<List<String>> {
  RecentSearchesNotifier() : super([]) {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = prefs.getStringList(AppConstants.keyRecentSearches);
      if (list != null && list.isNotEmpty) {
        state = list;
      } else {
        // Initial suggested defaults
        state = ['#rice', '#chicken', '#breakfast', '#malnad'];
      }
    } catch (_) {}
  }

  Future<void> addSearch(String query) async {
    final clean = query.trim();
    if (clean.isEmpty) return;

    final updated = List<String>.from(state);
    updated.remove(clean);
    updated.insert(0, clean);
    if (updated.length > 15) {
      updated.removeLast();
    }
    state = updated;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(AppConstants.keyRecentSearches, updated);
    } catch (_) {}
  }

  Future<void> removeSearch(String query) async {
    final updated = List<String>.from(state)..remove(query);
    state = updated;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(AppConstants.keyRecentSearches, updated);
    } catch (_) {}
  }

  Future<void> clearAll() async {
    state = [];
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.keyRecentSearches);
    } catch (_) {}
  }
}

final recentSearchesProvider = StateNotifierProvider<RecentSearchesNotifier, List<String>>((ref) {
  return RecentSearchesNotifier();
});
