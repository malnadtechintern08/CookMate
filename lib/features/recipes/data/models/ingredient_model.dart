import '../../domain/entities/ingredient.dart';

class IngredientModel extends Ingredient {
  const IngredientModel({
    super.id,
    required super.name,
    required super.amount,
    required super.unit,
  });

  factory IngredientModel.fromMap(Map<String, dynamic> map) {
    return IngredientModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      amount: (map['amount'] as num).toDouble(),
      unit: map['unit'] as String,
    );
  }

  Map<String, dynamic> toMap(String recipeId) {
    final map = <String, dynamic>{
      'recipe_id': recipeId,
      'name': name,
      'amount': amount,
      'unit': unit,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
}
