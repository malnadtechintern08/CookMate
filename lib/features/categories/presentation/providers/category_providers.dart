import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/database_service.dart';
import '../../data/datasources/category_local_datasource.dart';
import '../../data/repositories/category_repository_impl.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../../domain/usecases/get_categories_usecase.dart';


// Data Source Provider
final categoryLocalDataSourceProvider = Provider<CategoryLocalDataSource>((ref) {
  final dbService = ref.watch(databaseServiceProvider);
  return CategoryLocalDataSourceImpl(dbService);
});

// Repository Provider
final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final dataSource = ref.watch(categoryLocalDataSourceProvider);
  return CategoryRepositoryImpl(dataSource);
});

// Use Cases Providers
final getCategoriesUseCaseProvider = Provider<GetCategoriesUseCase>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return GetCategoriesUseCase(repository);
});

final getCategoryByIdUseCaseProvider = Provider<GetCategoryByIdUseCase>((ref) {
  final repository = ref.watch(categoryRepositoryProvider);
  return GetCategoryByIdUseCase(repository);
});

// Presentation State Providers
final categoriesProvider = FutureProvider.autoDispose<List<Category>>((ref) async {
  final useCase = ref.watch(getCategoriesUseCaseProvider);
  return await useCase.execute();
});

final selectedCategoryByIdProvider = FutureProvider.family.autoDispose<Category?, String>((ref, id) async {
  final useCase = ref.watch(getCategoryByIdUseCaseProvider);
  return await useCase.execute(id);
});
