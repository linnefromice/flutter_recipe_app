import '../models/ingredient_item.dart';

class RecipeCalculator {
  /// Recalculates all ingredient amounts based on the changed ingredient.
  /// Always computes from baseAmount to prevent cumulative rounding errors.
  static List<IngredientItem> recalculate({
    required List<IngredientItem> ingredients,
    required String changedIngredientId,
    required double newValue,
  }) {
    final changed =
        ingredients.firstWhere((i) => i.id == changedIngredientId);
    if (changed.baseAmount == 0 || newValue <= 0) return ingredients;

    final ratio = newValue / changed.baseAmount;

    return ingredients.map((ingredient) {
      if (ingredient.id == changedIngredientId) {
        return ingredient.copyWith(currentAmount: newValue);
      } else {
        return ingredient.copyWith(
            currentAmount: ingredient.baseAmount * ratio);
      }
    }).toList();
  }

  /// Returns the current scaling ratio relative to base amounts.
  static double getCurrentRatio({
    required List<IngredientItem> ingredients,
    required String referenceIngredientId,
  }) {
    final ref =
        ingredients.firstWhere((i) => i.id == referenceIngredientId);
    if (ref.baseAmount == 0) return 1.0;
    return ref.currentAmount / ref.baseAmount;
  }

  /// Resets all ingredients to their base amounts.
  static List<IngredientItem> resetToBase(List<IngredientItem> ingredients) {
    return ingredients
        .map((i) => i.copyWith(currentAmount: i.baseAmount))
        .toList();
  }
}
