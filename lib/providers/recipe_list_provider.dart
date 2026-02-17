import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

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
