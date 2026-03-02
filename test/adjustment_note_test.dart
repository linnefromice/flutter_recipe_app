import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_recipe_app/models/adjustment_note.dart';
import 'package:flutter_recipe_app/models/note_item.dart';

void main() {
  group('AdjustmentNote', () {
    test('toJson/fromJson ラウンドトリップ', () {
      final note = AdjustmentNote.create(
        recipeId: 'recipe-1',
        recipeName: 'テストレシピ',
        title: 'テストタイトル',
        items: const [
          NoteItem(name: '小麦粉', baseAmount: 100, adjustedAmount: 150),
          NoteItem(name: '砂糖', baseAmount: 50, adjustedAmount: 75),
        ],
        ratio: 1.5,
        memo: 'テストメモ',
      );

      final json = note.toJson();
      final restored = AdjustmentNote.fromJson(json);

      expect(restored.id, note.id);
      expect(restored.recipeId, 'recipe-1');
      expect(restored.recipeName, 'テストレシピ');
      expect(restored.title, 'テストタイトル');
      expect(restored.items.length, 2);
      expect(restored.items[0].name, '小麦粉');
      expect(restored.items[0].adjustedAmount, 150);
      expect(restored.ratio, 1.5);
      expect(restored.memo, 'テストメモ');
    });

    test('タイトルのデフォルト値は「調整メモ」', () {
      final note = AdjustmentNote.create(
        recipeId: 'recipe-1',
        recipeName: 'テストレシピ',
        items: const [],
        ratio: 1.0,
      );

      expect(note.title, '調整メモ');
    });

    test('空文字のタイトルはデフォルト値になる', () {
      final note = AdjustmentNote.create(
        recipeId: 'recipe-1',
        recipeName: 'テストレシピ',
        title: '',
        items: const [],
        ratio: 1.0,
      );

      expect(note.title, '調整メモ');
    });

    test('fromJson: title がない場合のデフォルト（後方互換）', () {
      final json = {
        'id': 'test-id',
        'recipeId': 'recipe-1',
        'recipeName': 'テストレシピ',
        'items': <Map<String, dynamic>>[],
        'ratio': 1.0,
        'createdAt': DateTime.now().toIso8601String(),
      };

      final note = AdjustmentNote.fromJson(json);
      expect(note.title, '調整メモ');
    });

    test('fromJson: adjustedIngredients キーの後方互換', () {
      final json = {
        'id': 'test-id',
        'recipeId': 'recipe-1',
        'recipeName': 'テストレシピ',
        'adjustedIngredients': [
          {
            'name': '小麦粉',
            'baseAmount': 100,
            'currentAmount': 150,
            'unit': 'g',
          },
        ],
        'ratio': 1.5,
        'createdAt': DateTime.now().toIso8601String(),
      };

      final note = AdjustmentNote.fromJson(json);
      expect(note.items.length, 1);
      expect(note.items[0].name, '小麦粉');
      expect(note.items[0].adjustedAmount, 150);
    });

    test('fromJson: items キーが優先される', () {
      final json = {
        'id': 'test-id',
        'recipeId': 'recipe-1',
        'recipeName': 'テストレシピ',
        'items': [
          {
            'name': '小麦粉',
            'baseAmount': 100,
            'adjustedAmount': 200,
            'unit': 'g',
          },
        ],
        'adjustedIngredients': [
          {
            'name': '砂糖',
            'baseAmount': 50,
            'currentAmount': 75,
            'unit': 'g',
          },
        ],
        'ratio': 2.0,
        'createdAt': DateTime.now().toIso8601String(),
      };

      final note = AdjustmentNote.fromJson(json);
      expect(note.items.length, 1);
      expect(note.items[0].name, '小麦粉');
      expect(note.items[0].adjustedAmount, 200);
    });
  });
}
