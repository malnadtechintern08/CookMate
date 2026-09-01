class ShoppingItem {
  final String id;
  final String name;
  final double amount;
  final String unit;
  final String recipeName;
  final bool isCompleted;
  final DateTime createdAt;

  const ShoppingItem({
    required this.id,
    required this.name,
    this.amount = 1.0,
    this.unit = '',
    this.recipeName = '',
    this.isCompleted = false,
    required this.createdAt,
  });

  String get formattedQuantity {
    if (amount <= 0 && unit.isEmpty) return '';
    final amtStr = (amount % 1 == 0) ? amount.toInt().toString() : amount.toString();
    if (unit.isEmpty) return amtStr;
    return '$amtStr $unit';
  }

  ShoppingItem copyWith({
    String? id,
    String? name,
    double? amount,
    String? unit,
    String? recipeName,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      name: name ?? this.name,
      amount: amount ?? this.amount,
      unit: unit ?? this.unit,
      recipeName: recipeName ?? this.recipeName,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'amount': amount,
      'unit': unit,
      'recipe_name': recipeName,
      'is_completed': isCompleted ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ShoppingItem.fromMap(Map<String, dynamic> map) {
    return ShoppingItem(
      id: map['id'] as String,
      name: map['name'] as String,
      amount: (map['amount'] as num?)?.toDouble() ?? 1.0,
      unit: (map['unit'] as String?) ?? '',
      recipeName: (map['recipe_name'] as String?) ?? '',
      isCompleted: (map['is_completed'] as num?) == 1,
      createdAt: DateTime.tryParse(map['created_at'] as String) ?? DateTime.now(),
    );
  }
}
