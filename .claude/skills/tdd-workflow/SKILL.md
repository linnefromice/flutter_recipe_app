---
name: tdd-workflow
description: "Flutter/Dart のTDDワークフロー。RED→GREEN→REFACTOR サイクルでテストファーストな実装を行う。新機能追加・バグ修正時に使用。"
---

# TDD Workflow

Flutter/Dart プロジェクトでのテスト駆動開発ワークフロー。

---

## ワークフロー

### Step 1: ユーザーストーリーを書く
```
[役割]として、[アクション]したい、それにより[メリット]を得る

例:
ユーザーとして、特定の材料量を入力したい、
それにより他の材料が比例計算されて表示される。
```

### Step 2: テストケースを設計
- 正常系: 基本的な計算が正しい
- 異常系: ゼロ除算、負の値
- エッジケース: 空リスト、非常に大きい値

### Step 3: RED — 失敗するテストを書く

```dart
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RecipeCalculator.recalculate', () {
    test('scales all ingredients proportionally', () {
      // Arrange
      final ingredients = [...];
      // Act
      final result = RecipeCalculator.recalculate(
        ingredients: ingredients,
        changedIngredientId: changedId,
        newValue: newValue,
      );
      // Assert
      expect(result[0].currentAmount, equals(expectedValue));
    });

    test('guards against zero baseAmount', () {
      // ゼロ除算のガードをテスト
    });
  });
}
```

```bash
flutter test test/services/recipe_calculator_test.dart
# → 失敗するはず
```

### Step 4: GREEN — 最小限の実装

テストを通す最小限のコードを書く。

```bash
flutter test test/services/recipe_calculator_test.dart
# → パスするはず
```

### Step 5: REFACTOR — 品質改善

テストがグリーンのまま:
- 重複を削除
- 命名を改善
- 可読性を向上

### Step 6: カバレッジ確認

```bash
flutter test --coverage
# 80% 以上を確認
```

---

## テストパターン

### Provider テスト（ProviderContainer）
```dart
late ProviderContainer container;

setUp(() {
  container = ProviderContainer(overrides: [
    storageServiceProvider.overrideWithValue(mockStorage),
  ]);
  addTearDown(container.dispose);
});
```

### Widget テスト（ProviderScope）
```dart
testWidgets('renders recipe list', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [...],
      child: const MaterialApp(home: RecipeListScreen()),
    ),
  );
  await tester.pumpAndSettle();
  expect(find.byType(ListTile), findsWidgets);
});
```

---

## 成功基準

- 80% 以上のカバレッジ
- すべてのテストがパス
- `flutter analyze` でエラーなし
- エッジケースがカバーされている
