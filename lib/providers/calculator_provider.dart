import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ingredient_item.dart';
import '../models/master_recipe.dart';
import '../services/recipe_calculator.dart';

class CalculatorState {
  final MasterRecipe originalRecipe;
  final List<IngredientItem> workingIngredients;
  final double currentRatio;
  final int? targetServings;

  const CalculatorState({
    required this.originalRecipe,
    required this.workingIngredients,
    this.currentRatio = 1.0,
    this.targetServings,
  });

  CalculatorState copyWith({
    List<IngredientItem>? workingIngredients,
    double? currentRatio,
    int? targetServings,
    bool clearTargetServings = false,
  }) {
    return CalculatorState(
      originalRecipe: originalRecipe,
      workingIngredients: workingIngredients ?? this.workingIngredients,
      currentRatio: currentRatio ?? this.currentRatio,
      targetServings:
          clearTargetServings ? null : (targetServings ?? this.targetServings),
    );
  }
}

final calculatorProvider = NotifierProvider.family
    .autoDispose<CalculatorNotifier, CalculatorState?, String>(
  CalculatorNotifier.new,
);

class CalculatorNotifier
    extends AutoDisposeFamilyNotifier<CalculatorState?, String> {
  @override
  CalculatorState? build(String arg) => null;

  void initialize(MasterRecipe recipe) {
    if (state != null) return;
    state = CalculatorState(
      originalRecipe: recipe,
      workingIngredients: recipe.ingredients
          .map((i) => i.copyWith(currentAmount: i.baseAmount))
          .toList(),
    );
  }

  void updateRecipe(MasterRecipe newRecipe) {
    final current = state;
    if (current == null) {
      initialize(newRecipe);
      return;
    }
    final currentRatio = current.currentRatio;
    state = CalculatorState(
      originalRecipe: newRecipe,
      workingIngredients: newRecipe.ingredients
          .map((i) => i.copyWith(currentAmount: i.baseAmount * currentRatio))
          .toList(),
      currentRatio: currentRatio,
    );
  }

  void updateIngredient(String ingredientId, double newValue) {
    final current = state;
    if (current == null) return;

    final recalculated = RecipeCalculator.recalculate(
      ingredients: current.workingIngredients,
      changedIngredientId: ingredientId,
      newValue: newValue,
    );

    final ratio = RecipeCalculator.getCurrentRatio(
      ingredients: recalculated,
      referenceIngredientId: ingredientId,
    );

    state = current.copyWith(
      workingIngredients: recalculated,
      currentRatio: ratio,
      clearTargetServings: true,
    );
  }

  void applyRatio(double ratio) {
    final current = state;
    if (current == null) return;
    final scaled = RecipeCalculator.scaleAll(
      ingredients: current.workingIngredients,
      ratio: ratio,
    );
    state = current.copyWith(
      workingIngredients: scaled,
      currentRatio: ratio,
      clearTargetServings: true,
    );
  }

  void applyServings(int targetServings) {
    final current = state;
    if (current == null) return;
    final baseServings = current.originalRecipe.servings;
    if (baseServings <= 0) return;
    final ratio = targetServings / baseServings;
    final scaled = RecipeCalculator.scaleAll(
      ingredients: current.workingIngredients,
      ratio: ratio,
    );
    state = current.copyWith(
      workingIngredients: scaled,
      currentRatio: ratio,
      targetServings: targetServings,
    );
  }

  void reset() {
    final current = state;
    if (current == null) return;
    state = current.copyWith(
      workingIngredients:
          RecipeCalculator.resetToBase(current.workingIngredients),
      currentRatio: 1.0,
      clearTargetServings: true,
    );
  }
}
