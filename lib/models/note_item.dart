import 'ingredient_item.dart';

class NoteItem {
  final String name;
  final double baseAmount;
  final double adjustedAmount;
  final String unit;

  const NoteItem({
    required this.name,
    required this.baseAmount,
    required this.adjustedAmount,
    this.unit = 'g',
  });

  factory NoteItem.fromIngredientItem(IngredientItem item) {
    return NoteItem(
      name: item.name,
      baseAmount: item.baseAmount,
      adjustedAmount: item.currentAmount,
      unit: item.unit,
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'baseAmount': baseAmount,
        'adjustedAmount': adjustedAmount,
        'unit': unit,
      };

  factory NoteItem.fromJson(Map<String, dynamic> json) {
    return NoteItem(
      name: json['name'] as String,
      baseAmount: (json['baseAmount'] as num).toDouble(),
      adjustedAmount: (json['adjustedAmount'] as num?)?.toDouble() ??
          (json['currentAmount'] as num).toDouble(),
      unit: json['unit'] as String? ?? 'g',
    );
  }
}
