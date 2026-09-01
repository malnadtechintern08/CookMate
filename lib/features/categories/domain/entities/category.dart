class Category {
  final String id;
  final String name;
  final String iconName;
  final String colorHex;
  final String description;
  final int recipeCount;

  const Category({
    required this.id,
    required this.name,
    required this.iconName,
    required this.colorHex,
    required this.description,
    this.recipeCount = 0,
  });

  Category copyWith({
    String? id,
    String? name,
    String? iconName,
    String? colorHex,
    String? description,
    int? recipeCount,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      colorHex: colorHex ?? this.colorHex,
      description: description ?? this.description,
      recipeCount: recipeCount ?? this.recipeCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
