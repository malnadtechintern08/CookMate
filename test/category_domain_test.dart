import 'package:flutter_test/flutter_test.dart';
import 'package:cookmate/features/categories/domain/entities/category.dart';
import 'package:cookmate/features/categories/domain/repositories/category_repository.dart';
import 'package:cookmate/features/categories/domain/usecases/get_categories_usecase.dart';

class MockCategoryRepository implements CategoryRepository {
  final List<Category> _categories = [
    const Category(
      id: 'cat_test_1',
      name: 'Italian Pastas',
      iconName: 'local_pizza',
      colorHex: '0xFFE8590C',
      description: 'Handcrafted pasta and sauces',
      recipeCount: 3,
    ),
    const Category(
      id: 'cat_test_2',
      name: 'Asian Bowls',
      iconName: 'ramen_dining',
      colorHex: '0xFFE03131',
      description: 'Noodles and broths',
      recipeCount: 2,
    ),
  ];

  @override
  Future<List<Category>> getCategories() async {
    return _categories;
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    try {
      return _categories.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}

void main() {
  group('Category Domain & Use Cases Tests', () {
    late MockCategoryRepository repository;
    late GetCategoriesUseCase getCategoriesUseCase;
    late GetCategoryByIdUseCase getCategoryByIdUseCase;

    setUp(() {
      repository = MockCategoryRepository();
      getCategoriesUseCase = GetCategoriesUseCase(repository);
      getCategoryByIdUseCase = GetCategoryByIdUseCase(repository);
    });

    test('GetCategoriesUseCase returns all categories', () async {
      final categories = await getCategoriesUseCase.execute();
      expect(categories.length, equals(2));
      expect(categories[0].name, equals('Italian Pastas'));
    });

    test('GetCategoryByIdUseCase returns correct category or null', () async {
      final cat = await getCategoryByIdUseCase.execute('cat_test_1');
      expect(cat, isNotNull);
      expect(cat!.name, equals('Italian Pastas'));

      final notFound = await getCategoryByIdUseCase.execute('cat_nonexistent');
      expect(notFound, isNull);
    });
  });
}
