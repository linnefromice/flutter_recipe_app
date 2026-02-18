---
description: "Dart/Flutter のコーディングスタイルルール"
globs: "lib/**/*.dart"
---

# コーディングスタイル

## イミュータビリティ

`copyWith` パターンでイミュータブル更新:

```dart
// 良い例
final updated = recipe.copyWith(name: '新しい名前');

// 悪い例
recipe.name = '新しい名前';
```

コレクションもイミュータブルに:

```dart
// 良い例
final updatedItems = [...items, newItem];

// 悪い例
items.add(newItem);
```

## ファクトリコンストラクタ

モデルは必ず factory コンストラクタを使用:
- `.create()` — UUID v4 による ID 自動生成
- `.fromJson()` — JSON デシリアライズ
- `toJson()` — JSON シリアライズ

## ファイル構成

- 200-400行が標準、最大800行
- 関数は50行未満
- ネストは4レベル以下

## エラーハンドリング

非同期処理は必ず例外処理:

```dart
try {
  final result = await asyncOperation();
  return result;
} catch (e) {
  // 適切なエラー処理
  rethrow;
}
```

## コード品質チェックリスト

- [ ] print() / debugPrint() がない
- [ ] ハードコードされた値がない
- [ ] UIテキストが日本語
- [ ] `flutter analyze` でエラーなし
