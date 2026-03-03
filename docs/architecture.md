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
│  Services / Utils（ロジック層）             │
│  RecipeCalculator / StorageService       │
│  amount_parser                           │
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
| `NoteItem` | 記録用材料（`baseAmount` + `adjustedAmount`、ID なし） |
| `MasterRecipe` | レシピ（名前 + 材料リスト） |
| `AdjustmentNote` | 調整記録（タイトル + 材料リスト + 倍率 + メモ） |

### 設計判断: baseAmount と currentAmount の分離

`IngredientItem` は `baseAmount`（レシピ原本の量）と `currentAmount`（計算後の量）を別フィールドで持つ。これにより：

- 計算は常に `baseAmount * ratio` で行い、累積丸め誤差を防止
- リセット時は `currentAmount = baseAmount` に戻すだけで済む
- UI で「(基準値)」を横に表示できる

### 設計判断: NoteItem と IngredientItem の分離

調整記録保存時、`IngredientItem` の `id`（UUID）はノートの文脈では不要なデータ。`NoteItem` は記録専用の軽量モデルとして分離し：

- `adjustedAmount`（`currentAmount` から改名）で記録の意図を明確化
- `baseAmount` も保持し、記録履歴で「基準量 → 調整量」の比較表示を可能に
- `NoteItem.fromIngredientItem()` で `IngredientItem` からの変換を提供
- `fromJson()` は旧データ（`currentAmount` キー）からの後方互換読み込みに対応

## Services（ロジック層）

### RecipeCalculator — 計算エンジン

**純粋関数（static メソッド）** として実装。Flutter・Riverpod に依存しない。

```
recalculate(ingredients, changedId, newValue)
  → ratio = newValue / changed.baseAmount
  → 他の材料: baseAmount * ratio
  → 変更した材料: newValue をそのまま使用

scaleAll(ingredients, ratio)
  → 全材料: baseAmount * ratio
  → ratio ≤ 0 の場合は元のリストを返す
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

### amount_parser — 入力パーサー

`utils/amount_parser.dart` に定義されたトップレベル関数。カンマ（`,`）を小数点として受け付ける国際化対応パーサー。

- `,` を `.` に正規化してから `double.tryParse`
- 非正値（0以下）は `null` を返す
- `IngredientInputTile` と `RecipeEditorScreen` の両方で共有

## Providers（状態管理層）

Riverpod を採用。Provider の種類を用途に応じて使い分けている。

| Provider | 種類 | 理由 |
|----------|------|------|
| `storageServiceProvider` | `Provider` | シングルトン。状態を持たない |
| `recipeListProvider` | `AsyncNotifierProvider` | Storage からの非同期読み込み + CRUD |
| `calculatorProvider` | `NotifierProvider.family.autoDispose` | レシピIDごとに独立した計算状態。画面を閉じると自動破棄 |
| `notesProvider` | `AsyncNotifierProvider.family` | レシピIDごとの記録。family でキャッシュを分離 |
| `recipeFilterProvider` | `NotifierProvider` | 検索クエリ・ソート順の管理。UIの表示条件を制御 |
| `filteredRecipeListProvider` | `Provider` | `recipeListProvider` + `recipeFilterProvider` の派生。フィルタ・ソート・お気に入り上位表示を適用 |

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
  ├── → RecipeEditorScreen（作成 ※+ボタン）
  ├── → RecipeEditorScreen（編集 ※編集アイコンから直接遷移）
  ├── → CalculatorScreen（計算）
  │       ├── → RecipeEditorScreen（編集）
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

`CalculatorState` は `targetServings`（`int?`）フィールドを持つ。`null` は倍率モード、値がある場合は人数モードを示す。`applyRatio()` や `updateIngredient()` で `null` にリセットされ、`applyServings()` で設定される。

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

## Golden Tests（ビジュアルリグレッション）

`alchemist` パッケージを使用した Golden Testing を導入。PR ベースで UI の意図しない変更を検出する。

### 仕組み

- **CI goldens** (`test/golden/goldens/ci/`): Ahem フォント（Flutter 内蔵）で生成。**CI 環境（Ubuntu）で自動生成・コミット**されるため、ローカル（macOS）では生成しない
- **Platform goldens** (`test/golden/goldens/<platform>/`): OS ネイティブフォントで生成。人間が読みやすいがOS依存のため `.gitignore` 対象

### 設定

- `test/flutter_test_config.dart`: `AlchemistConfig` でテーマ（`Colors.orange` + Material 3）と CI/Platform モードを制御
- `bool.fromEnvironment('CI')`: `--dart-define=CI=true`（コンパイル時定義）で CI 判定。OS 環境変数ではない

### テスト構成

| ファイル | シナリオ |
|---------|---------|
| `recipe_list_screen_golden_test.dart` | 空リスト、レシピ3件表示 |
| `calculator_screen_golden_test.dart` | 初期状態 (x1.00)、倍率変更後 (x1.50) |
| `recipe_editor_screen_golden_test.dart` | 新規作成モード、編集モード |
| `notes_screen_golden_test.dart` | メモなし、メモ2件表示 |

### テストインフラ

- `test/helpers/test_fixtures.dart`: 固定 ID・固定日時の決定論的テストデータ
- `test/helpers/golden_test_helpers.dart`: `GoldenTestApp`（ProviderScope ラッパー）+ Fake Notifier 群
- Provider オーバーライド: `recipeListOverride()`, `notesOverride()`, `calculatorOverride()`

### コマンド

```bash
flutter test --update-goldens test/golden/   # ベースライン更新
flutter test test/golden/                     # ローカル検証
flutter test --tags golden --dart-define=CI=true  # CI 実行
```

## CI/CD パイプライン

GitHub Actions で品質管理と配布を分離。

### CI (`ci.yml`)
- **トリガー**: `main` への push + Pull Request
- **build ジョブ**: `flutter analyze` → `flutter test --exclude-tags golden`
- **golden ジョブ**: CI golden ベースラインの管理 + リグレッション検証
  - PR 時: Ubuntu 上で `--update-goldens` を実行し、変更があれば自動コミット → その後テスト検証
  - push 時（main）: 既存の CI goldens に対してテスト検証のみ
  - 失敗時: 差分画像を `golden-failures` アーティファクトとしてアップロード（7日間保持）

### App Distribution (`distribute.yml`)
- **トリガー**: `main` への push のみ
- Java 17 セットアップ → `flutter build apk --release` → Firebase App Distribution アップロード
- 認証: Google Cloud Service Account（GitHub Secrets）
- 配布先: `internal-testers` グループ（メール通知）
- Firebase SDK はアプリに未組込。APK アップロードのみ利用
