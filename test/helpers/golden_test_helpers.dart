import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_recipe_app/models/adjustment_note.dart';
import 'package:flutter_recipe_app/models/master_recipe.dart';
import 'package:flutter_recipe_app/providers/calculator_provider.dart';
import 'package:flutter_recipe_app/providers/notes_provider.dart';
import 'package:flutter_recipe_app/providers/recipe_list_provider.dart';

/// Wraps a widget with [ProviderScope] for golden tests.
///
/// Does NOT include [MaterialApp] because Alchemist provides its own
/// via [AlchemistConfig.theme].
class GoldenTestApp extends StatelessWidget {
  final List<Override> overrides;
  final Widget child;

  const GoldenTestApp({
    super.key,
    required this.overrides,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: overrides,
      child: child,
    );
  }
}

// --- Fake Notifiers ---

class _FakeRecipeListNotifier extends RecipeListNotifier {
  final List<MasterRecipe> _recipes;

  _FakeRecipeListNotifier(this._recipes);

  @override
  FutureOr<List<MasterRecipe>> build() {
    state = AsyncData(_recipes);
    return _recipes;
  }
}

class _FakeNotesNotifier extends NotesNotifier {
  final Map<String, List<AdjustmentNote>> _dataMap;

  _FakeNotesNotifier(this._dataMap);

  @override
  FutureOr<List<AdjustmentNote>> build(String arg) {
    final notes = _dataMap[arg] ?? [];
    state = AsyncData(notes);
    return notes;
  }
}

class _FakeCalculatorNotifier extends CalculatorNotifier {
  final Map<String, CalculatorState?> _dataMap;

  _FakeCalculatorNotifier(this._dataMap);

  @override
  CalculatorState? build(String arg) => _dataMap[arg];

  @override
  void initialize(MasterRecipe recipe) {
    // no-op: state is already set via build()
  }
}

// --- Provider Override Helpers ---

Override recipeListOverride(List<MasterRecipe> recipes) {
  return recipeListProvider.overrideWith(() => _FakeRecipeListNotifier(recipes));
}

/// Overrides [notesProvider] for all family keys.
///
/// Pass a map of recipeId → notes list.
Override notesOverrides(Map<String, List<AdjustmentNote>> dataMap) {
  return notesProvider.overrideWith(() => _FakeNotesNotifier(dataMap));
}

/// Overrides [calculatorProvider] for all family keys.
///
/// Pass a map of recipeId → calculator state.
Override calculatorOverrides(Map<String, CalculatorState?> dataMap) {
  return calculatorProvider.overrideWith(() => _FakeCalculatorNotifier(dataMap));
}
