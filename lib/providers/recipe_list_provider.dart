import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ingredient_item.dart';
import '../models/master_recipe.dart';
import '../services/storage_service.dart';
import 'notes_provider.dart';

final storageServiceProvider = Provider<StorageService>((ref) => StorageService());

final recipeListProvider =
    AsyncNotifierProvider<RecipeListNotifier, List<MasterRecipe>>(
        RecipeListNotifier.new);

class RecipeListNotifier extends AsyncNotifier<List<MasterRecipe>> {
  @override
  FutureOr<List<MasterRecipe>> build() {
    return ref.read(storageServiceProvider).loadRecipes();
  }

  Future<void> addRecipe(MasterRecipe recipe) async {
    final storage = ref.read(storageServiceProvider);
    final current = state.valueOrNull ?? [];
    final updated = [...current, recipe];
    await storage.saveRecipes(updated);
    state = AsyncData(updated);
  }

  Future<void> updateRecipe(MasterRecipe recipe) async {
    final storage = ref.read(storageServiceProvider);
    final current = state.valueOrNull ?? [];
    final updated =
        current.map((r) => r.id == recipe.id ? recipe : r).toList();
    await storage.saveRecipes(updated);
    state = AsyncData(updated);
  }

  Future<void> duplicateRecipe(String recipeId) async {
    final storage = ref.read(storageServiceProvider);
    final current = state.valueOrNull ?? [];
    final original = current.firstWhere((r) => r.id == recipeId);
    final duplicate = MasterRecipe.create(
      name: '${original.name}（コピー）',
      description: original.description,
      ingredients: original.ingredients
          .map((i) => IngredientItem.create(
                name: i.name,
                baseAmount: i.baseAmount,
                unit: i.unit,
              ))
          .toList(),
      servings: original.servings,
    );
    final updated = [...current, duplicate];
    await storage.saveRecipes(updated);
    state = AsyncData(updated);
  }

  Future<void> toggleFavorite(String recipeId) async {
    final storage = ref.read(storageServiceProvider);
    final current = state.valueOrNull ?? [];
    final updated = current
        .map((r) =>
            r.id == recipeId ? r.copyWith(isFavorite: !r.isFavorite) : r)
        .toList();
    await storage.saveRecipes(updated);
    state = AsyncData(updated);
  }

  Future<void> deleteRecipe(String id) async {
    final storage = ref.read(storageServiceProvider);
    final current = state.valueOrNull ?? [];
    final updated = current.where((r) => r.id != id).toList();
    await Future.wait([
      storage.saveRecipes(updated),
      storage.deleteNotes(id),
    ]);
    ref.invalidate(notesProvider(id));
    state = AsyncData(updated);
  }
}
