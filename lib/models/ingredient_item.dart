import 'package:uuid/uuid.dart';

class IngredientItem {
  final String id;
  final String name;
  final double baseAmount;
  final double currentAmount;
  final String unit;

  const IngredientItem({
    required this.id,
    required this.name,
    required this.baseAmount,
    required this.currentAmount,
    this.unit = 'g',
  });

  factory IngredientItem.create({
    required String name,
    required double baseAmount,
    String unit = 'g',
  }) {
    return IngredientItem(
      id: const Uuid().v4(),
      name: name,
      baseAmount: baseAmount,
      currentAmount: baseAmount,
      unit: unit,
    );
  }

  IngredientItem copyWith({
    String? name,
    double? baseAmount,
    double? currentAmount,
    String? unit,
  }) {
    return IngredientItem(
      id: id,
      name: name ?? this.name,
      baseAmount: baseAmount ?? this.baseAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      unit: unit ?? this.unit,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'baseAmount': baseAmount,
        'currentAmount': currentAmount,
        'unit': unit,
      };

  factory IngredientItem.fromJson(Map<String, dynamic> json) {
    return IngredientItem(
      id: json['id'] as String,
      name: json['name'] as String,
      baseAmount: (json['baseAmount'] as num).toDouble(),
      currentAmount: (json['currentAmount'] as num).toDouble(),
      unit: json['unit'] as String? ?? 'g',
    );
  }
}
