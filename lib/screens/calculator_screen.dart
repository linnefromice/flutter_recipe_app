import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/adjustment_note.dart';
import '../models/master_recipe.dart';
import '../models/note_item.dart';
import '../providers/calculator_provider.dart';
import '../providers/notes_provider.dart';
import '../providers/recipe_list_provider.dart';
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
      ref.read(calculatorProvider(widget.recipe.id).notifier).initialize(widget.recipe);
    });
  }

  void _showSaveNoteDialog() {
    final titleController = TextEditingController();
    final memoController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('調整記録を保存'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                hintText: 'タイトル（空欄の場合「調整メモ」）',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: memoController,
              decoration: const InputDecoration(
                hintText: 'メモ（任意）',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              final calcState = ref.read(calculatorProvider(widget.recipe.id));
              if (calcState == null) return;
              final note = AdjustmentNote.create(
                recipeId: widget.recipe.id,
                recipeName: widget.recipe.name,
                title: titleController.text.trim(),
                items: calcState.workingIngredients
                    .map(NoteItem.fromIngredientItem)
                    .toList(),
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

  static const _presetRatios = [0.5, 1.0, 1.5, 2.0, 3.0];

  Widget _buildPresetChips(CalculatorState calcState, ThemeData theme) {
    final notifier = ref.read(calculatorProvider(widget.recipe.id).notifier);
    final isCustom = !_presetRatios.contains(calcState.currentRatio);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Wrap(
        spacing: 8,
        children: [
          ..._presetRatios.map((ratio) => ChoiceChip(
                label: Text('x${ratio == ratio.truncate() ? ratio.truncate().toString() : ratio.toString()}'),
                selected: calcState.currentRatio == ratio,
                onSelected: (_) => notifier.applyRatio(ratio),
                visualDensity: VisualDensity.compact,
              )),
          ChoiceChip(
            label: const Text('カスタム'),
            selected: isCustom,
            onSelected: (_) => _showCustomRatioDialog(),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildServingsBar(CalculatorState calcState, ThemeData theme) {
    final notifier = ref.read(calculatorProvider(widget.recipe.id).notifier);
    final baseServings = calcState.originalRecipe.servings;
    final currentServings = calcState.targetServings ?? baseServings;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Text('人数: $baseServings人前 →',
              style: theme.textTheme.bodyMedium),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 20),
            onPressed: currentServings > 1
                ? () => notifier.applyServings(currentServings - 1)
                : null,
            visualDensity: VisualDensity.compact,
          ),
          Text('$currentServings人前',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 20),
            onPressed: () => notifier.applyServings(currentServings + 1),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  void _showCustomRatioDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('カスタム倍率'),
        content: TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
          ],
          decoration: const InputDecoration(
            hintText: '倍率を入力（例: 1.25）',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              final value = double.tryParse(controller.text);
              if (value != null && value > 0) {
                ref
                    .read(calculatorProvider(widget.recipe.id).notifier)
                    .applyRatio(value);
                Navigator.pop(ctx);
              }
            },
            child: const Text('適用'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final calcState = ref.watch(calculatorProvider(widget.recipe.id));
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
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      RecipeEditorScreen(existingRecipe: widget.recipe),
                ),
              );
              if (result == true && mounted) {
                final recipeList =
                    ref.read(recipeListProvider).valueOrNull;
                final updatedRecipe = recipeList?.firstWhere(
                  (r) => r.id == widget.recipe.id,
                  orElse: () => widget.recipe,
                );
                if (updatedRecipe != null) {
                  ref
                      .read(calculatorProvider(widget.recipe.id).notifier)
                      .updateRecipe(updatedRecipe);
                }
              }
            },
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
                          ref.read(calculatorProvider(widget.recipe.id).notifier).reset(),
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
          _buildPresetChips(calcState, theme),
          if (calcState.originalRecipe.servings > 1)
            _buildServingsBar(calcState, theme),
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
                        .read(calculatorProvider(widget.recipe.id).notifier)
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
