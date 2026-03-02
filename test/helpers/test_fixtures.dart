import 'package:flutter_recipe_app/models/adjustment_note.dart';
import 'package:flutter_recipe_app/models/ingredient_item.dart';
import 'package:flutter_recipe_app/models/master_recipe.dart';
import 'package:flutter_recipe_app/models/note_item.dart';
import 'package:flutter_recipe_app/providers/calculator_provider.dart';

/// Deterministic test fixtures for golden tests.
///
/// All IDs and dates are fixed to ensure reproducible golden images.
class TestFixtures {
  TestFixtures._();

  static final _fixedDate = DateTime(2025, 1, 15, 10, 30);

  // --- Ingredient Items ---

  static const flour = IngredientItem(
    id: 'ing-001',
    name: '薄力粉',
    baseAmount: 200,
    currentAmount: 200,
    unit: 'g',
  );

  static const sugar = IngredientItem(
    id: 'ing-002',
    name: '砂糖',
    baseAmount: 80,
    currentAmount: 80,
    unit: 'g',
  );

  static const butter = IngredientItem(
    id: 'ing-003',
    name: 'バター',
    baseAmount: 100,
    currentAmount: 100,
    unit: 'g',
  );

  static const egg = IngredientItem(
    id: 'ing-004',
    name: '卵',
    baseAmount: 2,
    currentAmount: 2,
    unit: '個',
  );

  static const milk = IngredientItem(
    id: 'ing-005',
    name: '牛乳',
    baseAmount: 150,
    currentAmount: 150,
    unit: 'ml',
  );

  // --- Adjusted Ingredients (x1.50) ---

  static const flourAdjusted = IngredientItem(
    id: 'ing-001',
    name: '薄力粉',
    baseAmount: 200,
    currentAmount: 300,
    unit: 'g',
  );

  static const sugarAdjusted = IngredientItem(
    id: 'ing-002',
    name: '砂糖',
    baseAmount: 80,
    currentAmount: 120,
    unit: 'g',
  );

  static const butterAdjusted = IngredientItem(
    id: 'ing-003',
    name: 'バター',
    baseAmount: 100,
    currentAmount: 150,
    unit: 'g',
  );

  static const eggAdjusted = IngredientItem(
    id: 'ing-004',
    name: '卵',
    baseAmount: 2,
    currentAmount: 3,
    unit: '個',
  );

  static const milkAdjusted = IngredientItem(
    id: 'ing-005',
    name: '牛乳',
    baseAmount: 150,
    currentAmount: 225,
    unit: 'ml',
  );

  // --- Master Recipes ---

  static final cookieRecipe = MasterRecipe(
    id: 'recipe-001',
    name: 'クッキー',
    description: 'サクサクバタークッキー',
    ingredients: [flour, sugar, butter, egg],
    createdAt: _fixedDate,
  );

  static final pancakeRecipe = MasterRecipe(
    id: 'recipe-002',
    name: 'パンケーキ',
    description: 'ふわふわパンケーキ',
    ingredients: [flour, sugar, egg, milk],
    createdAt: _fixedDate.add(const Duration(hours: 1)),
  );

  static final chocolateCakeRecipe = MasterRecipe(
    id: 'recipe-003',
    name: 'チョコレートケーキ',
    description: '濃厚チョコレートケーキ',
    ingredients: [flour, sugar, butter, egg, milk],
    createdAt: _fixedDate.add(const Duration(hours: 2)),
  );

  static final threeRecipes = [
    cookieRecipe,
    pancakeRecipe,
    chocolateCakeRecipe,
  ];

  // --- Calculator States ---

  static final calculatorInitialState = CalculatorState(
    originalRecipe: cookieRecipe,
    workingIngredients: cookieRecipe.ingredients,
    currentRatio: 1.0,
  );

  static final calculatorAdjustedState = CalculatorState(
    originalRecipe: cookieRecipe,
    workingIngredients: [
      flourAdjusted,
      sugarAdjusted,
      butterAdjusted,
      eggAdjusted,
    ],
    currentRatio: 1.5,
  );

  // --- Adjustment Notes ---

  static final note150 = AdjustmentNote(
    id: 'note-001',
    recipeId: 'recipe-001',
    recipeName: 'クッキー',
    title: '1.5倍量',
    items: const [
      NoteItem(name: '薄力粉', baseAmount: 200, adjustedAmount: 300, unit: 'g'),
      NoteItem(name: '砂糖', baseAmount: 80, adjustedAmount: 120, unit: 'g'),
      NoteItem(name: 'バター', baseAmount: 100, adjustedAmount: 150, unit: 'g'),
      NoteItem(name: '卵', baseAmount: 2, adjustedAmount: 3, unit: '個'),
    ],
    ratio: 1.5,
    memo: 'パーティー用に1.5倍で作成',
    createdAt: _fixedDate.add(const Duration(days: 1)),
  );

  static final note050 = AdjustmentNote(
    id: 'note-002',
    recipeId: 'recipe-001',
    recipeName: 'クッキー',
    title: '半量',
    items: const [
      NoteItem(name: '薄力粉', baseAmount: 200, adjustedAmount: 100, unit: 'g'),
      NoteItem(name: '砂糖', baseAmount: 80, adjustedAmount: 40, unit: 'g'),
      NoteItem(name: 'バター', baseAmount: 100, adjustedAmount: 50, unit: 'g'),
      NoteItem(name: '卵', baseAmount: 2, adjustedAmount: 1, unit: '個'),
    ],
    ratio: 0.5,
    memo: '少量お試し用',
    createdAt: _fixedDate.add(const Duration(days: 2)),
  );

  static final twoNotes = [note150, note050];
}
