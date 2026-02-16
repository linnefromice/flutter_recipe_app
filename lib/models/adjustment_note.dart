import 'package:uuid/uuid.dart';

import 'ingredient_item.dart';

class AdjustmentNote {
  final String id;
  final String recipeId;
  final String recipeName;
  final List<IngredientItem> adjustedIngredients;
  final double ratio;
  final String memo;
  final DateTime createdAt;

  const AdjustmentNote({
    required this.id,
    required this.recipeId,
    required this.recipeName,
    required this.adjustedIngredients,
    required this.ratio,
    this.memo = '',
    required this.createdAt,
  });

  factory AdjustmentNote.create({
    required String recipeId,
    required String recipeName,
    required List<IngredientItem> adjustedIngredients,
    required double ratio,
    String memo = '',
  }) {
    return AdjustmentNote(
      id: const Uuid().v4(),
      recipeId: recipeId,
      recipeName: recipeName,
      adjustedIngredients: adjustedIngredients,
      ratio: ratio,
      memo: memo,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'recipeId': recipeId,
        'recipeName': recipeName,
        'adjustedIngredients':
            adjustedIngredients.map((i) => i.toJson()).toList(),
        'ratio': ratio,
        'memo': memo,
        'createdAt': createdAt.toIso8601String(),
      };

  factory AdjustmentNote.fromJson(Map<String, dynamic> json) {
    return AdjustmentNote(
      id: json['id'] as String,
      recipeId: json['recipeId'] as String,
      recipeName: json['recipeName'] as String,
      adjustedIngredients: (json['adjustedIngredients'] as List)
          .map((i) => IngredientItem.fromJson(i as Map<String, dynamic>))
          .toList(),
      ratio: (json['ratio'] as num).toDouble(),
      memo: json['memo'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
