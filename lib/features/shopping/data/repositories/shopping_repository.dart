import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/shopping_item.dart';

final shoppingRepositoryProvider = Provider<ShoppingRepository>((ref) {
  return ShoppingRepository();
});

class ShoppingRepository {
  Future<List<ShoppingItem>> getShoppingList() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = prefs.getStringList(AppConstants.keyShoppingList) ?? [];
      return jsonList
          .map((itemStr) => ShoppingItem.fromMap(json.decode(itemStr) as Map<String, dynamic>))
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      return [];
    }
  }

  Future<void> saveShoppingList(List<ShoppingItem> items) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = items.map((i) => json.encode(i.toMap())).toList();
      await prefs.setStringList(AppConstants.keyShoppingList, jsonList);
    } catch (_) {}
  }
}
