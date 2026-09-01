import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.iconName,
    required super.colorHex,
    required super.description,
    super.recipeCount,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map, [int recipeCount = 0]) {
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      iconName: map['icon_name'] as String,
      colorHex: map['color_hex'] as String,
      description: map['description'] as String,
      recipeCount: recipeCount,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon_name': iconName,
      'color_hex': colorHex,
      'description': description,
    };
  }
}
