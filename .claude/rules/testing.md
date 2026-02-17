---
description: "テスト要件とTDD規約"
globs: "{lib,test}/**/*.dart"
---

# テスト要件

## カバレッジ目標: 80%

### テストタイプ

| タイプ | 対象 | ツール |
|--------|------|--------|
| ユニットテスト | モデル、サービス、Provider ロジック | flutter_test |
| ウィジェットテスト | UI コンポーネントの描画・インタラクション | flutter_test |
| 統合テスト | 画面遷移、ユーザーフロー | integration_test |

### 優先テスト対象

1. `RecipeCalculator` の計算ロジック（100% 目標）
2. モデルの `toJson()` / `fromJson()` の対称性
3. Provider のビジネスロジック
4. 画面のインタラクション

## TDD ワークフロー

1. テストを書く（RED）
2. `flutter test` — 失敗するはず
3. 最小限の実装（GREEN）
4. `flutter test` — パスするはず
5. リファクタリング（IMPROVE）
6. カバレッジ確認（`flutter test --coverage`）

## エッジケース

必ずカバーすべきケース:
- ゼロ除算（baseAmount = 0）
- 空リスト（材料なし）
- 非正値（負の量）
- null / 空文字列
- 大量データ
