import 'package:flutter_test/flutter_test.dart';
import 'package:cookmate/features/tags/domain/entities/tag.dart';
import 'package:cookmate/features/tags/data/models/tag_model.dart';
import 'package:cookmate/features/tags/data/datasources/tag_remote_datasource.dart';
import 'package:cookmate/features/tags/data/repositories/tag_repository_impl.dart';

void main() {
  group('Tag Entity & TagModel Tests', () {
    test('Tag properties and displayName format', () {
      const tag = Tag(id: 149, name: 'rice', slug: 'rice', usageCount: 24);

      expect(tag.id, 149);
      expect(tag.name, 'rice');
      expect(tag.slug, 'rice');
      expect(tag.usageCount, 24);
      expect(tag.displayName, '#rice');
    });

    test('Tag equality and hashing', () {
      const tag1 = Tag(id: 1, name: 'veg', slug: 'veg');
      const tag2 = Tag(id: 1, name: 'veg', slug: 'veg');
      const tag3 = Tag(id: 2, name: 'nonveg', slug: 'nonveg');

      expect(tag1, equals(tag2));
      expect(tag1.hashCode, equals(tag2.hashCode));
      expect(tag1, isNot(equals(tag3)));
    });

    test('TagModel fromMap correctly parses JSON types', () {
      final json = {
        'id': '10',
        'name': '  south_indian  ',
        'slug': 'south_indian',
        'usage_count': '69',
      };

      final model = TagModel.fromMap(json);

      expect(model.id, 10);
      expect(model.name, 'south_indian');
      expect(model.slug, 'south_indian');
      expect(model.usageCount, 69);
      expect(model.displayName, '#south_indian');
    });

    test('TagModel toMap produces correct map structure', () {
      const model = TagModel(id: 5, name: 'chicken', slug: 'chicken', usageCount: 15);
      final map = model.toMap();

      expect(map['id'], 5);
      expect(map['name'], 'chicken');
      expect(map['slug'], 'chicken');
      expect(map['usage_count'], 15);
    });
  });

  group('TagRepository Fallback & Normalization Tests', () {
    test('TagRepository returns fallback popular tags if remote fails', () async {
      final repo = TagRepositoryImpl(MockFailingRemoteDataSource());
      final tags = await repo.getPopularTags();

      expect(tags, isNotEmpty);
      expect(tags.any((t) => t.name == 'rice'), isTrue);
      expect(tags.any((t) => t.name == 'veg'), isTrue);
      expect(tags.any((t) => t.name == 'malnad'), isTrue);
    });

    test('TagRepository offline tag search filters accurately', () async {
      final repo = TagRepositoryImpl(MockFailingRemoteDataSource());
      final results = await repo.searchTags('#rice');

      expect(results.length, 1);
      expect(results.first.name, 'rice');
      expect(results.first.displayName, '#rice');
    });
  });
}

class MockFailingRemoteDataSource implements TagRemoteDataSource {
  @override
  Future<List<TagModel>> fetchPopularTags({int limit = 15}) async {
    throw Exception('Simulated network error');
  }

  @override
  Future<List<TagModel>> searchTags(String query, {int limit = 10}) async {
    throw Exception('Simulated network error');
  }

  @override
  Future<Map<String, dynamic>> fetchRecipesByTag({
    required String tag,
    int page = 1,
    int limit = 20,
  }) async {
    throw Exception('Simulated network error');
  }

  @override
  Future<Map<String, dynamic>> searchRecipesUnified({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    throw Exception('Simulated network error');
  }
}
