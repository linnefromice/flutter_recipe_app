# アーキテクチャ設計

## 概要

本アプリは「特定の材料の量を指定すると、基準比率を維持したまま他の全材料を自動計算する」レシピ計算機。レイヤードアーキテクチャを採用し、各層の責務を明確に分離している。

## レイヤー構成

```
┌─────────────────────────────────────────┐
│  Screens / Widgets（UI層）               │
│  ConsumerWidget / ConsumerStatefulWidget │
├─────────────────────────────────────────┤
│  Providers（状態管理層）                  │
│  Notifier / AsyncNotifier               │
├─────────────────────────────────────────┤
│  Services（ロジック層）                   │
│  RecipeCalculator / StorageService       │
├─────────────────────────────────────────┤
│  Models（データ層）                       │
│  Immutable data classes                  │
└─────────────────────────────────────────┘
```

**依存の方向**: UI → Providers → Services → Models（上から下への一方向）

## Models（データ層）

すべてのモデルは **immutable** で、`copyWith` と JSON シリアライズを持つ。

| モデル | 役割 |
|--------|------|
| `IngredientItem` | 材料（`baseAmount` = 基準量、`currentAmount` = 計算後の量） |
| `MasterRecipe` | レシピ（名前 + 材料リスト） |
| `AdjustmentNote` | 調整記録（調整後の材料リスト + 倍率 + メモ） |

### 設計判断: baseAmount と currentAmount の分離

`IngredientItem` は `baseAmount`（レシピ原本の量）と `currentAmount`（計算後の量）を別フィールドで持つ。これにより：

- 計算は常に `baseAmount * ratio` で行い、累積丸め誤差を防止
- リセット時は `currentAmount = baseAmount` に戻すだけで済む
- UI で「(基準値)」を横に表示できる

## Services（ロジック層）

### RecipeCalculator — 計算エンジン

**純粋関数（static メソッド）** として実装。Flutter・Riverpod に依存しない。

```
recalculate(ingredients, changedId, newValue)
  → ratio = newValue / changed.baseAmount
  → 他の材料: baseAmount * ratio
  → 変更した材料: newValue をそのまま使用
```

**なぜ純粋関数か**:
- ユニットテストに Flutter/Riverpod のセットアップが不要
- Provider から切り離されているため、別のアーキテクチャに移行しても再利用可能
- 入力→出力が明確で、バグの原因特定が容易

### StorageService — 永続化

`shared_preferences` + JSON 文字列で CRUD を提供。

- レシピ一覧: `recipes` キーに JSON 配列として保存
- 調整記録: `notes_{recipeId}` キーにレシピごとに保存
- **カスケード削除**: レシピ削除時、対応する `notes_{recipeId}` も自動削除

**移行パス**: データ量が増えた場合、このクラスの内部実装を `sqflite` に差し替えるだけで対応可能（インターフェースは変わらない）。

## Providers（状態管理層）

Riverpod を採用。Provider の種類を用途に応じて使い分けている。

| Provider | 種類 | 理由 |
|----------|------|------|
| `storageServiceProvider` | `Provider` | シングルトン。状態を持たない |
| `recipeListProvider` | `AsyncNotifierProvider` | Storage からの非同期読み込み + CRUD |
| `calculatorProvider` | `NotifierProvider.family.autoDispose` | レシピIDごとに独立した計算状態。画面を閉じると自動破棄 |
| `notesProvider` | `AsyncNotifierProvider.family` | レシピIDごとの記録。family でキャッシュを分離 |

### AsyncNotifier vs Notifier の使い分け

- **AsyncNotifier**: 初期データが非同期（Storage からの読み込み）→ loading/error/data の3状態を型で表現
- **Notifier**: 初期データが同期的（既に手元にあるレシピから初期化）→ nullable で未初期化を表現

### calculatorProvider の設計判断

`calculatorProvider` は `family.autoDispose` を採用している。

- **family**: レシピIDをキーにすることで、レシピごとに独立したキャッシュを持つ。画面遷移時に前のレシピの状態が残らない
- **autoDispose**: 画面を閉じると自動的に状態が破棄される。メモリリークを防ぎ、次回開いたときは常に基準値（ratio = 1.0）から開始

初期化は `initState` + `addPostFrameCallback` パターンを使用。これは Riverpod の制約（build 内で ref.read できない）を回避するための公式推奨パターン。

### family Provider のメリット

`notesProvider` は `AsyncNotifierProvider.family<..., String>` で、レシピIDをキーにしている。

- レシピごとに独立したキャッシュ → レシピAの記録更新がレシピBの再描画を引き起こさない
- レシピ一覧画面で各カードが `ref.watch(notesProvider(recipe.id))` → 件数バッジの自動更新

## Screens（画面構成）

```
RecipeListScreen（一覧）
  ├── → RecipeEditorScreen（作成/編集）
  ├── → CalculatorScreen（計算）
  │       └── → NotesScreen（記録履歴）
  └── → NotesScreen（記録履歴 ※カードから直接遷移）
```

| 画面 | Widget種別 | 理由 |
|------|-----------|------|
| RecipeListScreen | `ConsumerWidget` | Provider を watch するだけ。ローカル状態不要 |
| RecipeEditorScreen | `ConsumerStatefulWidget` | TextEditingController 群のライフサイクル管理が必要 |
| CalculatorScreen | `ConsumerStatefulWidget` | initState で Calculator を初期化する必要がある |
| NotesScreen | `ConsumerWidget` | Provider を watch するだけ |

### CalculatorProvider の更新戦略

`CalculatorNotifier` は2つの初期化系メソッドを持つ:

- `initialize(MasterRecipe)`: 新規に計算を開始する場合。全材料を `currentAmount = baseAmount` で初期化
- `updateRecipe(MasterRecipe)`: レシピ編集後の更新。現在の倍率を維持したまま、新しいレシピ構成に差し替える

編集画面から戻った際は `updateRecipe()` を使用することで、ユーザーの計算状態（倍率）を失わずに最新のレシピデータを反映できる。

## データフロー: ライブ計算

アプリの中核機能のデータフロー:

```
ユーザーが TextField に入力
  → IngredientInputTile.onChanged
  → CalculatorNotifier.updateIngredient(id, newValue)
  → RecipeCalculator.recalculate()（純粋関数）
  → state = newState（immutable 更新）
  → ref.watch で UI が自動再描画
  → 他の IngredientInputTile が新しい値を表示
```

### TextField カーソル飛び防止

`IngredientInputTile` は `didUpdateWidget` 内で **フォーカスがない場合のみ** `controller.text` を更新する。フォーカス中のフィールドは外部からの値更新をスキップすることで、ユーザーの入力中にカーソル位置がリセットされるのを防ぐ。

## 数値精度の方針

- **内部**: `double` の完全精度で保持
- **表示**: 整数なら小数点なし、それ以外は `toStringAsFixed(1)`
- **計算**: 常に `baseAmount * ratio` から算出（`currentAmount` の連鎖計算を避ける）
