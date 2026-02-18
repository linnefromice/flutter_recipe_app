---
name: coding-standards
description: "Dart/Flutter/Riverpod のコーディング標準。命名規則、イミュータビリティ、Provider設計、エラーハンドリングのパターン集。"
---

# Coding Standards

Dart/Flutter/Riverpod プロジェクトのコーディング標準。

---

## 命名規則

| 対象 | 規則 | 例 |
|------|------|-----|
| クラス | UpperCamelCase | `MasterRecipe`, `RecipeCalculator` |
| 変数・関数 | lowerCamelCase | `baseAmount`, `recalculate()` |
| 定数 | lowerCamelCase | `defaultServings` |
| ファイル | snake_case | `master_recipe.dart` |
| Provider | lowerCamelCase + Provider | `recipeListProvider` |

## イミュータビリティパターン

### モデル
```dart
class MyModel {
  final String id;
  final String name;

  const MyModel({required this.id, required this.name});

  // factory コンストラクタ
  factory MyModel.create({required String name}) {
    return MyModel(id: uuid.v4(), name: name);
  }

  factory MyModel.fromJson(Map<String, dynamic> json) {
    return MyModel(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};

  MyModel copyWith({String? name}) {
    return MyModel(id: id, name: name ?? this.name);
  }
}
```

### コレクション操作
```dart
// 追加
final updated = [...items, newItem];
// 削除
final updated = items.where((e) => e.id != targetId).toList();
// 更新
final updated = items.map((e) => e.id == targetId ? e.copyWith(name: newName) : e).toList();
```

## Riverpod Provider 設計

| パターン | 用途 | 例 |
|---------|------|-----|
| AsyncNotifierProvider | 非同期データ + 操作 | `recipeListProvider` |
| NotifierProvider | 同期状態 + 操作 | `calculatorProvider` |
| FamilyAsyncNotifierProvider | ID別の非同期データ | `notesProvider` |
| Provider | 依存関係の提供 | `storageServiceProvider` |

## エラーハンドリング

### 計算ロジック
```dart
// ゼロ除算ガード
if (baseAmount <= 0) return ingredients; // 元の値を返す

// 比例計算
final ratio = newValue / baseAmount;
```

### 非同期操作
```dart
// Provider 内
state = const AsyncLoading();
state = await AsyncValue.guard(() async {
  return await someAsyncOperation();
});
```

## ファイル構成

```
lib/
├── models/       # データモデル（イミュータブル、toJson/fromJson）
├── services/     # ビジネスロジック（純粋関数推奨）
├── providers/    # Riverpod 状態管理
└── screens/      # UI（Widget）
```

## 原則

- **KISS**: シンプルに保つ
- **DRY**: 繰り返さない（ただし早すぎる抽象化も避ける）
- **YAGNI**: 今必要でないものは作らない
- **単一責任**: 1ファイル・1クラスに1つの責任
