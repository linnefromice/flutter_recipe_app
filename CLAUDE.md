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
