import '../../../../core/database/database_service.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/category_model.dart';

abstract class CategoryLocalDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<CategoryModel?> getCategoryById(String id);
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  final DatabaseService databaseService;

  CategoryLocalDataSourceImpl(this.databaseService);

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final db = await databaseService.database;
      final results = await db.rawQuery('''
        SELECT c.*, COUNT(r.id) as recipe_count
        FROM categories c
        LEFT JOIN recipes r ON c.id = r.category_id
        GROUP BY c.id
        ORDER BY c.name ASC
      ''');

      return results.map((row) {
        final count = (row['recipe_count'] as num?)?.toInt() ?? 0;
        return CategoryModel.fromMap(row, count);
      }).toList();
    } catch (e) {
      throw AppDatabaseException('Failed to fetch categories: $e');
    }
  }

  @override
  Future<CategoryModel?> getCategoryById(String id) async {
    try {
      final db = await databaseService.database;
      final results = await db.rawQuery('''
        SELECT c.*, COUNT(r.id) as recipe_count
        FROM categories c
        LEFT JOIN recipes r ON c.id = r.category_id
        WHERE c.id = ?
        GROUP BY c.id
      ''', [id]);

      if (results.isEmpty) return null;
      final count = (results.first['recipe_count'] as num?)?.toInt() ?? 0;
      return CategoryModel.fromMap(results.first, count);
    } catch (e) {
      throw AppDatabaseException('Failed to fetch category by ID: $e');
    }
  }
}
