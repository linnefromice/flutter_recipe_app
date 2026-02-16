import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_recipe_app/models/ingredient_item.dart';
import 'package:flutter_recipe_app/services/recipe_calculator.dart';

void main() {
  final ingredients = [
    const IngredientItem(
        id: 'flour', name: '小麦粉', baseAmount: 100, currentAmount: 100),
    const IngredientItem(
        id: 'sugar', name: '砂糖', baseAmount: 50, currentAmount: 50),
    const IngredientItem(
        id: 'butter', name: 'バター', baseAmount: 30, currentAmount: 30),
  ];

  group('RecipeCalculator.recalculate', () {
    test('scales all ingredients when one is changed', () {
      final result = RecipeCalculator.recalculate(
        ingredients: ingredients,
        changedIngredientId: 'flour',
        newValue: 150, // 1.5x
      );

      expect(result[0].currentAmount, 150.0);
      expect(result[1].currentAmount, 75.0);
      expect(result[2].currentAmount, 45.0);
    });

    test('handles scaling down', () {
      final result = RecipeCalculator.recalculate(
        ingredients: ingredients,
        changedIngredientId: 'sugar',
        newValue: 25, // 0.5x
      );

      expect(result[0].currentAmount, 50.0);
      expect(result[1].currentAmount, 25.0);
      expect(result[2].currentAmount, 15.0);
    });

    test('returns original if baseAmount is 0', () {
      final withZero = [
        const IngredientItem(
            id: 'a', name: 'A', baseAmount: 0, currentAmount: 0),
        const IngredientItem(
            id: 'b', name: 'B', baseAmount: 50, currentAmount: 50),
      ];

      final result = RecipeCalculator.recalculate(
        ingredients: withZero,
        changedIngredientId: 'a',
        newValue: 10,
      );

      expect(result[0].currentAmount, 0.0);
      expect(result[1].currentAmount, 50.0);
    });

    test('returns original if newValue is 0 or negative', () {
      final result = RecipeCalculator.recalculate(
        ingredients: ingredients,
        changedIngredientId: 'flour',
        newValue: 0,
      );

      expect(result[0].currentAmount, 100.0);
    });
  });

  group('RecipeCalculator.getCurrentRatio', () {
    test('returns correct ratio', () {
      final scaled = RecipeCalculator.recalculate(
        ingredients: ingredients,
        changedIngredientId: 'flour',
        newValue: 135,
      );

      final ratio = RecipeCalculator.getCurrentRatio(
        ingredients: scaled,
        referenceIngredientId: 'flour',
      );

      expect(ratio, 1.35);
    });
  });

  group('RecipeCalculator.resetToBase', () {
    test('resets all amounts to base', () {
      final scaled = RecipeCalculator.recalculate(
        ingredients: ingredients,
        changedIngredientId: 'flour',
        newValue: 200,
      );

      final reset = RecipeCalculator.resetToBase(scaled);

      for (final i in reset) {
        expect(i.currentAmount, i.baseAmount);
      }
    });
  });
}
