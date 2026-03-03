import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_recipe_app/models/ingredient_item.dart';
import 'package:flutter_recipe_app/models/master_recipe.dart';

void main() {
  final ingredients = [
    const IngredientItem(
      id: 'ing-1',
      name: '小麦粉',
      baseAmount: 100,
      currentAmount: 100,
      unit: 'g',
    ),
    const IngredientItem(
      id: 'ing-2',
      name: '砂糖',
      baseAmount: 50,
      currentAmount: 50,
      unit: 'g',
    ),
  ];

  final recipe = MasterRecipe(
    id: 'test-id',
    name: 'テストレシピ',
    description: 'テスト用',
    ingredients: ingredients,
    createdAt: DateTime(2025, 1, 1),
    servings: 4,
    isFavorite: true,
  );

  group('MasterRecipe toJson/fromJson round-trip', () {
    test('servings と isFavorite が正しくシリアライズされる', () {
      final json = recipe.toJson();

      expect(json['servings'], 4);
      expect(json['isFavorite'], true);

      final restored = MasterRecipe.fromJson(json);

      expect(restored.id, recipe.id);
      expect(restored.name, recipe.name);
      expect(restored.description, recipe.description);
      expect(restored.servings, 4);
      expect(restored.isFavorite, true);
      expect(restored.ingredients.length, 2);
      expect(restored.createdAt, recipe.createdAt);
    });

    test('デフォルト値でも正しくラウンドトリップする', () {
      final defaultRecipe = MasterRecipe(
        id: 'default-id',
        name: 'デフォルト',
        ingredients: ingredients,
        createdAt: DateTime(2025, 1, 1),
      );

      final json = defaultRecipe.toJson();
      expect(json['servings'], 1);
      expect(json['isFavorite'], false);

      final restored = MasterRecipe.fromJson(json);
      expect(restored.servings, 1);
      expect(restored.isFavorite, false);
    });
  });

  group('MasterRecipe.fromJson 後方互換性', () {
    test('servings キーがない場合デフォルト値 1 が使われる', () {
      final json = {
        'id': 'old-id',
        'name': '旧レシピ',
        'description': '',
        'ingredients': ingredients.map((i) => i.toJson()).toList(),
        'createdAt': DateTime(2025, 1, 1).toIso8601String(),
      };

      final restored = MasterRecipe.fromJson(json);
      expect(restored.servings, 1);
    });

    test('isFavorite キーがない場合デフォルト値 false が使われる', () {
      final json = {
        'id': 'old-id',
        'name': '旧レシピ',
        'ingredients': ingredients.map((i) => i.toJson()).toList(),
        'createdAt': DateTime(2025, 1, 1).toIso8601String(),
      };

      final restored = MasterRecipe.fromJson(json);
      expect(restored.isFavorite, false);
    });
  });

  group('MasterRecipe.copyWith', () {
    test('servings を更新できる', () {
      final updated = recipe.copyWith(servings: 6);
      expect(updated.servings, 6);
      expect(updated.isFavorite, true);
      expect(updated.name, recipe.name);
    });

    test('isFavorite を更新できる', () {
      final updated = recipe.copyWith(isFavorite: false);
      expect(updated.isFavorite, false);
      expect(updated.servings, 4);
    });

    test('両フィールド同時に更新できる', () {
      final updated = recipe.copyWith(servings: 8, isFavorite: false);
      expect(updated.servings, 8);
      expect(updated.isFavorite, false);
    });

    test('指定しないフィールドは元の値を保持する', () {
      final updated = recipe.copyWith(name: '新しい名前');
      expect(updated.name, '新しい名前');
      expect(updated.servings, 4);
      expect(updated.isFavorite, true);
    });
  });

  group('MasterRecipe.create', () {
    test('servings を指定して作成できる', () {
      final created = MasterRecipe.create(
        name: '新レシピ',
        ingredients: ingredients,
        servings: 3,
      );
      expect(created.servings, 3);
      expect(created.isFavorite, false);
      expect(created.id, isNotEmpty);
    });

    test('servings 省略時はデフォルト値 1', () {
      final created = MasterRecipe.create(
        name: '新レシピ',
        ingredients: ingredients,
      );
      expect(created.servings, 1);
    });
  });
}
