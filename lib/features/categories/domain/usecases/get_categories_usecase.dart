import '../entities/category.dart';
import '../repositories/category_repository.dart';

class GetCategoriesUseCase {
  final CategoryRepository repository;

  const GetCategoriesUseCase(this.repository);

  Future<List<Category>> execute() async {
    return await repository.getCategories();
  }
}

class GetCategoryByIdUseCase {
  final CategoryRepository repository;

  const GetCategoryByIdUseCase(this.repository);

  Future<Category?> execute(String id) async {
    return await repository.getCategoryById(id);
  }
}
