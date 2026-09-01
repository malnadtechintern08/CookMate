class Ingredient {
  final int? id;
  final String name;
  final double amount;
  final String unit;

  const Ingredient({
    this.id,
    required this.name,
    required this.amount,
    required this.unit,
  });

  Ingredient copyWith({
    int? id,
    String? name,
    double? amount,
    String? unit,
  }) {
    return Ingredient(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
    );
  }

  // Helper method to scale amounts according to serving sizes
  Ingredient scale(double factor) {
    return Ingredient(
      id: id,
      name: name,
      amount: double.parse((amount * factor).toStringAsFixed(2)),
      unit: unit,
    );
  }
}
