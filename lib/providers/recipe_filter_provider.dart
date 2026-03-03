import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/master_recipe.dart';
import 'recipe_list_provider.dart';

enum RecipeSortOrder { nameAscending, createdNewest, createdOldest }

class RecipeFilterState {
  final String searchQuery;
  final RecipeSortOrder sortOrder;

  const RecipeFilterState({
    this.searchQuery = '',
    this.sortOrder = RecipeSortOrder.createdNewest,
  });

  RecipeFilterState copyWith({
    String? searchQuery,
    RecipeSortOrder? sortOrder,
  }) {
    return RecipeFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

final recipeFilterProvider =
    NotifierProvider<RecipeFilterNotifier, RecipeFilterState>(
        RecipeFilterNotifier.new);

class RecipeFilterNotifier extends Notifier<RecipeFilterState> {
  @override
  RecipeFilterState build() => const RecipeFilterState();

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSortOrder(RecipeSortOrder order) {
    state = state.copyWith(sortOrder: order);
  }

  void clearSearch() {
    state = state.copyWith(searchQuery: '');
  }
}

final filteredRecipeListProvider =
    Provider<AsyncValue<List<MasterRecipe>>>((ref) {
  final recipesAsync = ref.watch(recipeListProvider);
  final filter = ref.watch(recipeFilterProvider);

  return recipesAsync.whenData((recipes) {
    var filtered = recipes.toList();

    // Search filter
    if (filter.searchQuery.isNotEmpty) {
      final query = filter.searchQuery.toLowerCase();
      filtered = filtered
          .where((r) => r.name.toLowerCase().contains(query))
          .toList();
    }

    // Sort
    switch (filter.sortOrder) {
      case RecipeSortOrder.nameAscending:
        filtered.sort((a, b) => a.name.compareTo(b.name));
      case RecipeSortOrder.createdNewest:
        filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      case RecipeSortOrder.createdOldest:
        filtered.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }

    // Favorites pinned to top
    final favorites = filtered.where((r) => r.isFavorite).toList();
    final nonFavorites = filtered.where((r) => !r.isFavorite).toList();
    return [...favorites, ...nonFavorites];
  });
});
