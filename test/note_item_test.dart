import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_recipe_app/models/ingredient_item.dart';
import 'package:flutter_recipe_app/models/note_item.dart';

void main() {
  group('NoteItem', () {
    test('toJson/fromJson ラウンドトリップ', () {
      const item = NoteItem(
        name: '小麦粉',
        baseAmount: 100,
        adjustedAmount: 150,
        unit: 'g',
      );
      final json = item.toJson();
      final restored = NoteItem.fromJson(json);

      expect(restored.name, '小麦粉');
      expect(restored.baseAmount, 100);
      expect(restored.adjustedAmount, 150);
      expect(restored.unit, 'g');
    });

    test('fromJson: currentAmount から adjustedAmount への後方互換', () {
      final json = {
        'name': '砂糖',
        'baseAmount': 50,
        'currentAmount': 75,
        'unit': 'g',
      };
      final item = NoteItem.fromJson(json);

      expect(item.adjustedAmount, 75);
    });

    test('fromJson: adjustedAmount が優先される', () {
      final json = {
        'name': '砂糖',
        'baseAmount': 50,
        'adjustedAmount': 80,
        'currentAmount': 75,
        'unit': 'g',
      };
      final item = NoteItem.fromJson(json);

      expect(item.adjustedAmount, 80);
    });

    test('fromJson: unit のデフォルトは g', () {
      final json = {
        'name': '塩',
        'baseAmount': 5,
        'adjustedAmount': 7.5,
      };
      final item = NoteItem.fromJson(json);

      expect(item.unit, 'g');
    });

    test('fromIngredientItem で IngredientItem から変換できる', () {
      final ingredient = IngredientItem.create(
        name: 'バター',
        baseAmount: 30,
        unit: 'g',
      );
      final updated = ingredient.copyWith(currentAmount: 45);
      final noteItem = NoteItem.fromIngredientItem(updated);

      expect(noteItem.name, 'バター');
      expect(noteItem.baseAmount, 30);
      expect(noteItem.adjustedAmount, 45);
      expect(noteItem.unit, 'g');
    });

    test('デフォルトの unit は g', () {
      const item = NoteItem(
        name: '水',
        baseAmount: 200,
        adjustedAmount: 300,
      );
      expect(item.unit, 'g');
    });
  });
}
