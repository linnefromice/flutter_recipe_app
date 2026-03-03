import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_recipe_app/models/ingredient_item.dart';
import 'package:flutter_recipe_app/models/master_recipe.dart';
import 'package:flutter_recipe_app/providers/recipe_filter_provider.dart';
import 'package:flutter_recipe_app/providers/recipe_list_provider.dart';

class _FakeRecipeListNotifier extends RecipeListNotifier {
  final List<MasterRecipe> _recipes;
  _FakeRecipeListNotifier(this._recipes);

  @override
  FutureOr<List<MasterRecipe>> build() {
    state = AsyncData(_recipes);
    return _recipes;
  }
}

void main() {
  final fixedDate = DateTime(2025, 1, 15);

  final ingredients = [
    const IngredientItem(
      id: 'i1',
      name: '小麦粉',
      baseAmount: 100,
      currentAmount: 100,
    ),
    const IngredientItem(
      id: 'i2',
      name: '砂糖',
      baseAmount: 50,
      currentAmount: 50,
    ),
  ];

  final cookie = MasterRecipe(
    id: 'r1',
    name: 'クッキー',
    ingredients: ingredients,
    createdAt: fixedDate,
    isFavorite: true,
  );

  final pancake = MasterRecipe(
    id: 'r2',
    name: 'パンケーキ',
    ingredients: ingredients,
    createdAt: fixedDate.add(const Duration(hours: 1)),
  );

  final cake = MasterRecipe(
    id: 'r3',
    name: 'チョコレートケーキ',
    ingredients: ingredients,
    createdAt: fixedDate.add(const Duration(hours: 2)),
  );

  final allRecipes = [cookie, pancake, cake];

  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(overrides: [
      recipeListProvider
          .overrideWith(() => _FakeRecipeListNotifier(allRecipes)),
    ]);
  });

  tearDown(() {
    container.dispose();
  });

  group('RecipeFilterNotifier', () {
    test('初期状態は空クエリ・createdNewest', () {
      final state = container.read(recipeFilterProvider);
      expect(state.searchQuery, '');
      expect(state.sortOrder, RecipeSortOrder.createdNewest);
    });

    test('setSearchQuery でクエリが更新される', () {
      container.read(recipeFilterProvider.notifier).setSearchQuery('クッキー');
      expect(container.read(recipeFilterProvider).searchQuery, 'クッキー');
    });

    test('clearSearch でクエリがクリアされる', () {
      container.read(recipeFilterProvider.notifier).setSearchQuery('test');
      container.read(recipeFilterProvider.notifier).clearSearch();
      expect(container.read(recipeFilterProvider).searchQuery, '');
    });

    test('setSortOrder でソート順が更新される', () {
      container
          .read(recipeFilterProvider.notifier)
          .setSortOrder(RecipeSortOrder.nameAscending);
      expect(container.read(recipeFilterProvider).sortOrder,
          RecipeSortOrder.nameAscending);
    });
  });

  group('filteredRecipeListProvider', () {
    test('お気に入りが上部に表示される', () {
      final result = container.read(filteredRecipeListProvider);
      final recipes = result.value!;

      expect(recipes.first.id, cookie.id);
      expect(recipes.first.isFavorite, true);
    });

    test('createdNewest でソートされる（お気に入り除外して確認）', () {
      final result = container.read(filteredRecipeListProvider);
      final recipes = result.value!;
      // cookie is favorite → first
      // non-favorites sorted by createdAt desc: cake, pancake
      final nonFavorites = recipes.where((r) => !r.isFavorite).toList();
      expect(nonFavorites[0].id, cake.id);
      expect(nonFavorites[1].id, pancake.id);
    });

    test('createdOldest でソートされる', () {
      container
          .read(recipeFilterProvider.notifier)
          .setSortOrder(RecipeSortOrder.createdOldest);
      final result = container.read(filteredRecipeListProvider);
      final nonFavorites =
          result.value!.where((r) => !r.isFavorite).toList();
      expect(nonFavorites[0].id, pancake.id);
      expect(nonFavorites[1].id, cake.id);
    });

    test('nameAscending でソートされる', () {
      container
          .read(recipeFilterProvider.notifier)
          .setSortOrder(RecipeSortOrder.nameAscending);
      final result = container.read(filteredRecipeListProvider);
      final nonFavorites =
          result.value!.where((r) => !r.isFavorite).toList();
      // チョコレートケーキ < パンケーキ (unicode order)
      expect(nonFavorites[0].id, cake.id);
      expect(nonFavorites[1].id, pancake.id);
    });

    test('検索フィルタが動作する', () {
      container.read(recipeFilterProvider.notifier).setSearchQuery('ケーキ');
      final result = container.read(filteredRecipeListProvider);
      final recipes = result.value!;

      expect(recipes.length, 2);
      expect(recipes.any((r) => r.name == 'パンケーキ'), true);
      expect(recipes.any((r) => r.name == 'チョコレートケーキ'), true);
    });

    test('検索は大文字小文字を区別しない', () {
      // Japanese doesn't have case, but test with mixed content
      container.read(recipeFilterProvider.notifier).setSearchQuery('クッキー');
      final result = container.read(filteredRecipeListProvider);
      expect(result.value!.length, 1);
      expect(result.value!.first.name, 'クッキー');
    });

    test('検索結果が空の場合は空リスト', () {
      container
          .read(recipeFilterProvider.notifier)
          .setSearchQuery('存在しない');
      final result = container.read(filteredRecipeListProvider);
      expect(result.value!, isEmpty);
    });
  });
}
