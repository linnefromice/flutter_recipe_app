# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Flutter recipe calculator app (Japanese UI). Given a specific ingredient amount, it proportionally recalculates all other ingredients while maintaining the base ratio. Dart SDK ^3.9.0.

## Commands

```bash
flutter pub get          # Install dependencies
flutter run              # Run the app
flutter test             # Run all tests
flutter test test/recipe_calculator_test.dart  # Run a single test file
flutter analyze          # Static analysis (uses flutter_lints)
```

## Architecture

**State management**: Riverpod (`flutter_riverpod`). The app wraps in `ProviderScope` at root.

**Data flow**: Models are immutable with `copyWith`, `toJson`/`fromJson`. Persistence uses `shared_preferences` with JSON serialization (no database).

### Key layers

- **Models** (`lib/models/`): `MasterRecipe` → has many `IngredientItem` (each tracks `baseAmount` + `currentAmount`). `AdjustmentNote` stores a snapshot of a calculation with memo.
- **Services** (`lib/services/`): `RecipeCalculator` — pure static methods, always computes from `baseAmount` to avoid cumulative rounding errors. `StorageService` — SharedPreferences wrapper using JSON strings.
- **Providers** (`lib/providers/`): `recipeListProvider` (AsyncNotifier), `calculatorProvider` (sync Notifier, nullable state), `notesProvider` (FamilyAsyncNotifier keyed by recipeId). `storageServiceProvider` is the shared dependency.
- **Screens** (`lib/screens/`): Recipe list → Calculator (live proportional editing) → Notes history. Recipe editor for create/edit.

### Navigation

Imperative `Navigator.push` with `MaterialPageRoute`. No named routes or router package.

### Core calculation logic

`RecipeCalculator.recalculate()` takes one changed ingredient and scales all others by `newValue / changedIngredient.baseAmount`. Division by zero and non-positive values are guarded.

## Documentation

プロジェクトのドキュメントは `docs/` に管理されている。コード変更時は関連するドキュメントも必ず更新すること。

- `docs/requirements.md` — 業務要件（ユーザーストーリー、受け入れ条件、画面仕様、データモデル、バリデーションルール）
  - 更新タイミング: 機能の追加・変更・削除、画面遷移の変更、データモデルの変更、バリデーションルールの変更
- `docs/architecture.md` — アーキテクチャ設計（レイヤー構成、Provider設計、データフロー）
  - 更新タイミング: レイヤー構成の変更、Provider の追加・変更、新しい設計パターンの導入、画面の追加・構成変更

**ルール**: コードの変更が上記ドキュメントの記載内容に影響する場合、同じコミットまたは同じ作業単位の中でドキュメントも更新する。ドキュメントとコードの乖離を防ぐ。

## Conventions

- All models use factory constructors (`.create()` with UUID generation, `.fromJson()`)
- UI text is in Japanese
- Material 3 with orange color scheme
- IDs are UUID v4 strings



## Agent Team Operational Rules

このプロジェクトでは Claude Code の Agent Teams を活用します。
以下のルールは全 Teammate に適用されます。

### チーム構成の原則

- 並列作業が有効なタスクでは、Agent Teams を積極的に活用する
- リード（team lead）は調整に専念し、実装はすべて Teammate が行う
- Delegate Mode（`Shift+Tab`）を使用してリードの実装を構造的に制限する

### Teammate の行動規範

- **能動的な取得**: 共有タスクリストから能動的に未着手タスクを claim すること
- **即時通信**: 共通インターフェースに影響が出る変更は、即座に関連 Teammate にメッセージを送ること
- **品質ゲート**: テストを実行せずにタスクを Complete とマークしないこと
- **コンテキスト共有**: 発見した重要な情報は他の Teammate と共有すること

### タスク設計ガイドライン

- 1人あたり 5〜6 タスクの粒度で分割する
- タスク間の依存関係を明示的に定義する
- リスクの高い変更には Plan approval を要求する

### ファイル競合の防止

- 2人の Teammate が同一ファイルを編集しないよう、担当範囲を分割する
- 共有ファイルへの変更が必要な場合は、事前に担当者間で調整する
