---
description: "TDDワークフローで機能を実装する"
---

# TDD

$ARGUMENTS をテスト駆動開発で実装してください。

## ワークフロー

### 1. テスト設計
- 対象機能のテストケースを洗い出す
- 正常系、異常系、エッジケースを含める

### 2. RED — 失敗するテストを書く
```bash
flutter test test/path_to_test.dart
# → 失敗するはず
```

### 3. GREEN — テストを通す最小限の実装
```bash
flutter test test/path_to_test.dart
# → パスするはず
```

### 4. REFACTOR — 品質改善
- テストをグリーンに保ちながらリファクタ
- `flutter analyze` でエラーなしを確認

### 5. カバレッジ確認
```bash
flutter test --coverage
```
- 目標: 80% 以上

## ルール

- テストを先に書くこと（実装を先に書かない）
- 各ステップで `flutter test` を実行して確認
- 既存テストを壊さないこと
