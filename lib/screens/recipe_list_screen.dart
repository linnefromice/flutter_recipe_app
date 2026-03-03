import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/notes_provider.dart';
import '../providers/recipe_filter_provider.dart';
import '../providers/recipe_list_provider.dart';
import '../widgets/recipe_card.dart';
import 'calculator_screen.dart';
import 'notes_screen.dart';
import 'recipe_editor_screen.dart';

class RecipeListScreen extends ConsumerStatefulWidget {
  const RecipeListScreen({super.key});

  @override
  ConsumerState<RecipeListScreen> createState() => _RecipeListScreenState();
}

class _RecipeListScreenState extends ConsumerState<RecipeListScreen> {
  bool _isSearching = false;
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        ref.read(recipeFilterProvider.notifier).clearSearch();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final recipesAsync = ref.watch(filteredRecipeListProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'レシピ名で検索...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  ref
                      .read(recipeFilterProvider.notifier)
                      .setSearchQuery(value);
                },
              )
            : const Text('レシピ一覧'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            tooltip: _isSearching ? '検索を閉じる' : '検索',
            onPressed: _toggleSearch,
          ),
          PopupMenuButton<RecipeSortOrder>(
            icon: const Icon(Icons.sort),
            tooltip: '並び替え',
            onSelected: (order) {
              ref.read(recipeFilterProvider.notifier).setSortOrder(order);
            },
            itemBuilder: (context) {
              final current = ref.read(recipeFilterProvider).sortOrder;
              return [
                CheckedPopupMenuItem(
                  value: RecipeSortOrder.createdNewest,
                  checked: current == RecipeSortOrder.createdNewest,
                  child: const Text('作成日時（新しい順）'),
                ),
                CheckedPopupMenuItem(
                  value: RecipeSortOrder.createdOldest,
                  checked: current == RecipeSortOrder.createdOldest,
                  child: const Text('作成日時（古い順）'),
                ),
                CheckedPopupMenuItem(
                  value: RecipeSortOrder.nameAscending,
                  checked: current == RecipeSortOrder.nameAscending,
                  child: const Text('名前順'),
                ),
              ];
            },
          ),
        ],
      ),
      body: recipesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('エラー: $error')),
        data: (recipes) {
          if (recipes.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.restaurant_menu,
                      size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    _isSearching ? '検索結果がありません' : 'レシピがありません',
                    style:
                        const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  if (!_isSearching)
                    const Text('右下のボタンから追加してください',
                        style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: recipes.length,
            itemBuilder: (context, index) {
              final recipe = recipes[index];
              final notesAsync = ref.watch(notesProvider(recipe.id));
              final noteCount = notesAsync.valueOrNull?.length ?? 0;
              return RecipeCard(
                recipe: recipe,
                noteCount: noteCount,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CalculatorScreen(recipe: recipe),
                  ),
                ),
                onEdit: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        RecipeEditorScreen(existingRecipe: recipe),
                  ),
                ),
                onNotesPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NotesScreen(
                      recipeId: recipe.id,
                      recipeName: recipe.name,
                    ),
                  ),
                ),
                onDelete: () => _confirmDelete(context, ref, recipe.id),
                onToggleFavorite: () => ref
                    .read(recipeListProvider.notifier)
                    .toggleFavorite(recipe.id),
                onDuplicate: () {
                  ref
                      .read(recipeListProvider.notifier)
                      .duplicateRecipe(recipe.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('レシピを複製しました')),
                  );
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const RecipeEditorScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('削除確認'),
        content: const Text('このレシピを削除しますか？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              ref.read(recipeListProvider.notifier).deleteRecipe(id);
              Navigator.pop(ctx);
            },
            child: const Text('削除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
