import '../../domain/entities/ingredient.dart';

class IngredientModel extends Ingredient {
  const IngredientModel({
    super.id,
    required super.name,
    required super.amount,
    required super.unit,
  });

  factory IngredientModel.fromMap(Map<String, dynamic> map) {
    final rawAmount = map['amount'];
    double parsedAmount = 1.0;
    if (rawAmount is num) {
      parsedAmount = rawAmount.toDouble();
    } else if (rawAmount != null) {
      parsedAmount = double.tryParse(rawAmount.toString()) ?? 1.0;
    }

    final rawId = map['id'];
    int? parsedId;
    if (rawId is int) {
      parsedId = rawId;
    } else if (rawId != null) {
      parsedId = int.tryParse(rawId.toString());
    }

    return IngredientModel(
      id: parsedId,
      name: (map['name'] as String?) ?? '',
      amount: parsedAmount,
      unit: (map['unit'] as String?) ?? '',
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
