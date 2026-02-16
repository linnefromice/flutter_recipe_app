import 'package:uuid/uuid.dart';

import 'ingredient_item.dart';

class MasterRecipe {
  final String id;
  final String name;
  final String description;
  final List<IngredientItem> ingredients;
  final DateTime createdAt;

  const MasterRecipe({
    required this.id,
    required this.name,
    this.description = '',
    required this.ingredients,
    required this.createdAt,
  });

  factory MasterRecipe.create({
    required String name,
    String description = '',
    required List<IngredientItem> ingredients,
  }) {
    return MasterRecipe(
      id: const Uuid().v4(),
      name: name,
      description: description,
      ingredients: ingredients,
      createdAt: DateTime.now(),
    );
  }

  MasterRecipe copyWith({
    String? name,
    String? description,
    List<IngredientItem>? ingredients,
  }) {
    return MasterRecipe(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      ingredients: ingredients ?? this.ingredients,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'ingredients': ingredients.map((i) => i.toJson()).toList(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory MasterRecipe.fromJson(Map<String, dynamic> json) {
    return MasterRecipe(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      ingredients: (json['ingredients'] as List)
          .map((i) => IngredientItem.fromJson(i as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
