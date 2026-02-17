import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_recipe_app/models/adjustment_note.dart';
import 'package:flutter_recipe_app/models/ingredient_item.dart';
import 'package:flutter_recipe_app/services/storage_service.dart';

void main() {
  late StorageService service;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    service = StorageService();
  });

  group('StorageService.deleteNotes', () {
    test('特定レシピの調整記録を削除できる', () async {
      const recipeId = 'test-recipe-id';
      final notes = [
        AdjustmentNote.create(
          recipeId: recipeId,
          recipeName: 'テストレシピ',
          adjustedIngredients: [
            IngredientItem.create(name: '小麦粉', baseAmount: 100),
          ],
          ratio: 1.5,
          memo: 'テストメモ',
        ),
      ];

      await service.saveNotes(recipeId, notes);
      var loaded = await service.loadNotes(recipeId);
      expect(loaded.length, 1);

      await service.deleteNotes(recipeId);
      loaded = await service.loadNotes(recipeId);
      expect(loaded, isEmpty);
    });

    test('存在しないレシピIDを削除してもエラーにならない', () async {
      await expectLater(
        service.deleteNotes('non-existent-id'),
        completes,
      );
    });

    test('他のレシピの記録には影響しない', () async {
      const recipeIdA = 'recipe-a';
      const recipeIdB = 'recipe-b';

      final notesA = [
        AdjustmentNote.create(
          recipeId: recipeIdA,
          recipeName: 'レシピA',
          adjustedIngredients: [],
          ratio: 1.0,
        ),
      ];
      final notesB = [
        AdjustmentNote.create(
          recipeId: recipeIdB,
          recipeName: 'レシピB',
          adjustedIngredients: [],
          ratio: 2.0,
        ),
      ];

      await service.saveNotes(recipeIdA, notesA);
      await service.saveNotes(recipeIdB, notesB);

      await service.deleteNotes(recipeIdA);

      final loadedA = await service.loadNotes(recipeIdA);
      final loadedB = await service.loadNotes(recipeIdB);
      expect(loadedA, isEmpty);
      expect(loadedB.length, 1);
    });
  });
}
