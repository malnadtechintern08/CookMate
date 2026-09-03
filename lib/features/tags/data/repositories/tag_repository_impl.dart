import '../../domain/entities/tag.dart';
import '../datasources/tag_remote_datasource.dart';

abstract class TagRepository {
  Future<List<Tag>> getPopularTags({int limit = 15});
  Future<List<Tag>> searchTags(String query, {int limit = 10});
  Future<Map<String, dynamic>> getRecipesByTag({
    required String tag,
    int page = 1,
    int limit = 20,
  });
  Future<Map<String, dynamic>> searchRecipesUnified({
    required String query,
    int page = 1,
    int limit = 20,
  });
}

class TagRepositoryImpl implements TagRepository {
  final TagRemoteDataSource remoteDataSource;

  TagRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Tag>> getPopularTags({int limit = 15}) async {
    try {
      final remote = await remoteDataSource.fetchPopularTags(limit: limit);
      if (remote.isNotEmpty) return remote;
    } catch (_) {}

    // Fallback seed tags if offline
    return const [
      Tag(id: 1, name: 'veg', slug: 'veg', usageCount: 168),
      Tag(id: 2, name: 'south_indian', slug: 'south_indian', usageCount: 69),
      Tag(id: 3, name: 'malnad', slug: 'malnad', usageCount: 51),
      Tag(id: 4, name: 'breakfast', slug: 'breakfast', usageCount: 28),
      Tag(id: 5, name: 'rice', slug: 'rice', usageCount: 24),
      Tag(id: 6, name: 'chicken', slug: 'chicken', usageCount: 15),
      Tag(id: 7, name: 'spicy', slug: 'spicy', usageCount: 12),
      Tag(id: 8, name: 'healthy', slug: 'healthy', usageCount: 10),
    ];
  }

  @override
  Future<List<Tag>> searchTags(String query, {int limit = 10}) async {
    try {
      return await remoteDataSource.searchTags(query, limit: limit);
    } catch (_) {
      // Local filter fallback
      final clean = query.toLowerCase().replaceAll('#', '').trim();
      final all = await getPopularTags(limit: 20);
      return all.where((t) => t.name.contains(clean)).toList();
    }
  }

  @override
  Future<Map<String, dynamic>> getRecipesByTag({
    required String tag,
    int page = 1,
    int limit = 20,
  }) async {
    return await remoteDataSource.fetchRecipesByTag(
      tag: tag,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<Map<String, dynamic>> searchRecipesUnified({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    return await remoteDataSource.searchRecipesUnified(
      query: query,
      page: page,
      limit: limit,
    );
  }
}
