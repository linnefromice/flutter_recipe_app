import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/adjustment_note.dart';
import '../models/master_recipe.dart';
import '../providers/calculator_provider.dart';
import '../providers/notes_provider.dart';
import '../widgets/ingredient_input_tile.dart';
import 'notes_screen.dart';
import 'recipe_editor_screen.dart';

class CalculatorScreen extends ConsumerStatefulWidget {
  final MasterRecipe recipe;

  const CalculatorScreen({super.key, required this.recipe});

  @override
  ConsumerState<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends ConsumerState<CalculatorScreen> {
  @override
  void initState() {
    super.initState();
    // Schedule initialization after the widget tree is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(calculatorProvider.notifier).initialize(widget.recipe);
    });
  }

  void _showSaveNoteDialog() {
    final memoController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('調整記録を保存'),
        content: TextField(
          controller: memoController,
          decoration: const InputDecoration(
            hintText: 'メモ（任意）',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              final calcState = ref.read(calculatorProvider);
              if (calcState == null) return;
              final note = AdjustmentNote.create(
                recipeId: widget.recipe.id,
                recipeName: widget.recipe.name,
                adjustedIngredients: calcState.workingIngredients,
                ratio: calcState.currentRatio,
                memo: memoController.text.trim(),
              );
              ref
                  .read(notesProvider(widget.recipe.id).notifier)
                  .addNote(note);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('記録を保存しました')),
              );
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final calcState = ref.watch(calculatorProvider);
    final theme = Theme.of(context);

    if (calcState == null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.recipe.name)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipe.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: '編集',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    RecipeEditorScreen(existingRecipe: widget.recipe),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: '記録履歴',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NotesScreen(
                  recipeId: widget.recipe.id,
                  recipeName: widget.recipe.name,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '倍率: x${calcState.currentRatio.toStringAsFixed(2)}',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    OutlinedButton.icon(
                      onPressed: () =>
                          ref.read(calculatorProvider.notifier).reset(),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('リセット'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _showSaveNoteDialog,
                      icon: const Icon(Icons.save_outlined, size: 18),
                      label: const Text('記録'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text('材料名',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                ),
                Expanded(
                  flex: 2,
                  child: Text('計算量',
                      style: theme.textTheme.bodySmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.right),
                ),
                SizedBox(
                  width: 68,
                  child: Text('(基準)',
                      style: theme.textTheme.bodySmall,
                      textAlign: TextAlign.right),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: calcState.workingIngredients.length,
              itemBuilder: (context, index) {
                final ingredient = calcState.workingIngredients[index];
                return IngredientInputTile(
                  key: ValueKey(ingredient.id),
                  ingredient: ingredient,
                  onChanged: (newValue) {
                    ref
                        .read(calculatorProvider.notifier)
                        .updateIngredient(ingredient.id, newValue);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
