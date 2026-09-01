import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_datasource.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource localDataSource;

  CategoryRepositoryImpl(this.localDataSource);

  @override
  Future<List<Category>> getCategories() async {
    return await localDataSource.getCategories();
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    return await localDataSource.getCategoryById(id);
  }
}
