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

## Conventions

- All models use factory constructors (`.create()` with UUID generation, `.fromJson()`)
- UI text is in Japanese
- Material 3 with orange color scheme
- IDs are UUID v4 strings
