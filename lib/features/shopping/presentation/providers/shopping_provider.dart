import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/shopping_item.dart';
import '../../data/repositories/shopping_repository.dart';
import '../../../recipes/domain/entities/ingredient.dart';

final shoppingListProvider = StateNotifierProvider<ShoppingListNotifier, List<ShoppingItem>>((ref) {
  final repo = ref.watch(shoppingRepositoryProvider);
  return ShoppingListNotifier(repo);
});

class ShoppingListNotifier extends StateNotifier<List<ShoppingItem>> {
  final ShoppingRepository _repository;
  static const _uuid = Uuid();

  ShoppingListNotifier(this._repository) : super([]) {
    _loadItems();
  }

  Future<void> _loadItems() async {
    final items = await _repository.getShoppingList();
    state = items;
  }

  Future<void> addItem({
    required String name,
    double amount = 1.0,
    String unit = '',
    String recipeName = '',
  }) async {
    final newItem = ShoppingItem(
      id: _uuid.v4(),
      name: name.trim(),
      amount: amount,
      unit: unit.trim(),
      recipeName: recipeName.trim(),
      isCompleted: false,
      createdAt: DateTime.now(),
    );

    final updated = [newItem, ...state];
    state = updated;
    await _repository.saveShoppingList(updated);
  }

  Future<void> addIngredientsFromRecipe({
    required List<Ingredient> ingredients,
    required String recipeTitle,
  }) async {
    final newItems = ingredients.map((ing) {
      return ShoppingItem(
        id: _uuid.v4(),
        name: ing.name,
        amount: ing.amount,
        unit: ing.unit,
        recipeName: recipeTitle,
        isCompleted: false,
        createdAt: DateTime.now(),
      );
    }).toList();

    final updated = [...newItems, ...state];
    state = updated;
    await _repository.saveShoppingList(updated);
  }

  Future<void> toggleItem(String id) async {
    final updated = state.map((item) {
      if (item.id == id) {
        return item.copyWith(isCompleted: !item.isCompleted);
      }
      return item;
    }).toList();

    state = updated;
    await _repository.saveShoppingList(updated);
  }

  Future<void> deleteItem(String id) async {
    final updated = state.where((item) => item.id != id).toList();
    state = updated;
    await _repository.saveShoppingList(updated);
  }

  Future<void> clearCompleted() async {
    final updated = state.where((item) => !item.isCompleted).toList();
    state = updated;
    await _repository.saveShoppingList(updated);
  }

  Future<void> clearAll() async {
    state = [];
    await _repository.saveShoppingList([]);
  }
}
