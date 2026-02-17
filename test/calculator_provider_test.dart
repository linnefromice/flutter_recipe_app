import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_recipe_app/models/ingredient_item.dart';
import 'package:flutter_recipe_app/models/master_recipe.dart';
import 'package:flutter_recipe_app/providers/calculator_provider.dart';

void main() {
  late ProviderContainer container;
  late MasterRecipe testRecipe;

  setUp(() {
    container = ProviderContainer();
    testRecipe = MasterRecipe.create(
      name: 'テストレシピ',
      ingredients: [
        IngredientItem.create(name: '小麦粉', baseAmount: 100),
        IngredientItem.create(name: '砂糖', baseAmount: 50),
        IngredientItem.create(name: 'バター', baseAmount: 30),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('calculatorProvider family.autoDispose', () {
    test('初期状態は null', () {
      final state = container.read(calculatorProvider(testRecipe.id));
      expect(state, isNull);
    });

    test('initialize で状態が設定される', () {
      container
          .read(calculatorProvider(testRecipe.id).notifier)
          .initialize(testRecipe);

      final state = container.read(calculatorProvider(testRecipe.id));
      expect(state, isNotNull);
      expect(state!.originalRecipe.id, testRecipe.id);
      expect(state.currentRatio, 1.0);
      expect(state.workingIngredients.length, 3);
      for (final i in state.workingIngredients) {
        expect(i.currentAmount, i.baseAmount);
      }
    });

    test('二重初期化は無視される', () {
      final notifier =
          container.read(calculatorProvider(testRecipe.id).notifier);
      notifier.initialize(testRecipe);
      notifier.updateIngredient(testRecipe.ingredients[0].id, 150);

      // 再度 initialize しても状態は変わらない
      notifier.initialize(testRecipe);

      final state = container.read(calculatorProvider(testRecipe.id))!;
      expect(state.currentRatio, 1.5);
    });

    test('異なるレシピIDで独立したキャッシュを持つ', () {
      final recipe2 = MasterRecipe.create(
        name: 'レシピ2',
        ingredients: [
          IngredientItem.create(name: '卵', baseAmount: 60),
          IngredientItem.create(name: '牛乳', baseAmount: 200),
        ],
      );

      container
          .read(calculatorProvider(testRecipe.id).notifier)
          .initialize(testRecipe);
      container
          .read(calculatorProvider(recipe2.id).notifier)
          .initialize(recipe2);

      final state1 = container.read(calculatorProvider(testRecipe.id))!;
      final state2 = container.read(calculatorProvider(recipe2.id))!;

      expect(state1.originalRecipe.id, testRecipe.id);
      expect(state2.originalRecipe.id, recipe2.id);
      expect(state1.workingIngredients.length, 3);
      expect(state2.workingIngredients.length, 2);
    });
  });

  group('CalculatorNotifier.updateRecipe', () {
    test('倍率を維持したまま新しいレシピに更新', () {
      final notifier =
          container.read(calculatorProvider(testRecipe.id).notifier);
      notifier.initialize(testRecipe);
      notifier.updateIngredient(testRecipe.ingredients[0].id, 150); // x1.5

      final updatedRecipe = testRecipe.copyWith(
        ingredients: [
          testRecipe.ingredients[0].copyWith(baseAmount: 120),
          testRecipe.ingredients[1],
          testRecipe.ingredients[2],
        ],
      );

      notifier.updateRecipe(updatedRecipe);
      final state = container.read(calculatorProvider(testRecipe.id))!;

      expect(state.currentRatio, 1.5);
      expect(state.workingIngredients[0].baseAmount, 120.0);
      expect(state.workingIngredients[0].currentAmount, 180.0); // 120 * 1.5
      expect(state.workingIngredients[1].currentAmount, 75.0); // 50 * 1.5
      expect(state.workingIngredients[2].currentAmount, 45.0); // 30 * 1.5
    });

    test('材料追加時、新しい材料にも倍率が適用される', () {
      final notifier =
          container.read(calculatorProvider(testRecipe.id).notifier);
      notifier.initialize(testRecipe);
      notifier.updateIngredient(testRecipe.ingredients[0].id, 200); // x2.0

      final updatedRecipe = testRecipe.copyWith(
        ingredients: [
          ...testRecipe.ingredients,
          IngredientItem.create(name: '卵', baseAmount: 60),
        ],
      );

      notifier.updateRecipe(updatedRecipe);
      final state = container.read(calculatorProvider(testRecipe.id))!;

      expect(state.workingIngredients.length, 4);
      expect(state.workingIngredients[3].name, '卵');
      expect(state.workingIngredients[3].currentAmount, 120.0); // 60 * 2.0
    });

    test('材料削除時、リストから消える', () {
      final notifier =
          container.read(calculatorProvider(testRecipe.id).notifier);
      notifier.initialize(testRecipe);

      final updatedRecipe = testRecipe.copyWith(
        ingredients: [testRecipe.ingredients[0], testRecipe.ingredients[1]],
      );

      notifier.updateRecipe(updatedRecipe);
      final state = container.read(calculatorProvider(testRecipe.id))!;

      expect(state.workingIngredients.length, 2);
      expect(state.workingIngredients.any((i) => i.name == 'バター'), false);
    });

    test('未初期化で updateRecipe を呼ぶと initialize と同じ挙動', () {
      final notifier =
          container.read(calculatorProvider(testRecipe.id).notifier);

      notifier.updateRecipe(testRecipe);
      final state = container.read(calculatorProvider(testRecipe.id))!;

      expect(state.currentRatio, 1.0);
      for (final i in state.workingIngredients) {
        expect(i.currentAmount, i.baseAmount);
      }
    });
  });

  group('CalculatorNotifier.updateIngredient', () {
    test('他の全材料が連動して再計算される', () {
      final notifier =
          container.read(calculatorProvider(testRecipe.id).notifier);
      notifier.initialize(testRecipe);

      notifier.updateIngredient(testRecipe.ingredients[0].id, 150);
      final state = container.read(calculatorProvider(testRecipe.id))!;

      expect(state.workingIngredients[0].currentAmount, 150.0);
      expect(state.workingIngredients[1].currentAmount, 75.0);
      expect(state.workingIngredients[2].currentAmount, 45.0);
      expect(state.currentRatio, 1.5);
    });
  });

  group('CalculatorNotifier.reset', () {
    test('全材料が基準値に戻り、倍率が1.0になる', () {
      final notifier =
          container.read(calculatorProvider(testRecipe.id).notifier);
      notifier.initialize(testRecipe);
      notifier.updateIngredient(testRecipe.ingredients[0].id, 200);

      notifier.reset();
      final state = container.read(calculatorProvider(testRecipe.id))!;

      expect(state.currentRatio, 1.0);
      for (final i in state.workingIngredients) {
        expect(i.currentAmount, i.baseAmount);
      }
    });
  });
}
