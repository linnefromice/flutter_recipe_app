import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/ingredient_item.dart';
import '../models/master_recipe.dart';
import '../providers/recipe_list_provider.dart';

class RecipeEditorScreen extends ConsumerStatefulWidget {
  final MasterRecipe? existingRecipe;

  const RecipeEditorScreen({super.key, this.existingRecipe});

  @override
  ConsumerState<RecipeEditorScreen> createState() => _RecipeEditorScreenState();
}

class _RecipeEditorScreenState extends ConsumerState<RecipeEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  final List<_IngredientEntry> _ingredients = [];

  bool get _isEditing => widget.existingRecipe != null;

  @override
  void initState() {
    super.initState();
    final recipe = widget.existingRecipe;
    _nameController = TextEditingController(text: recipe?.name ?? '');
    _descriptionController =
        TextEditingController(text: recipe?.description ?? '');
    if (recipe != null) {
      for (final i in recipe.ingredients) {
        _ingredients.add(_IngredientEntry(
          id: i.id,
          nameController: TextEditingController(text: i.name),
          amountController:
              TextEditingController(text: i.baseAmount.toString()),
          unitController: TextEditingController(text: i.unit),
        ));
      }
    } else {
      _addEmptyIngredient();
      _addEmptyIngredient();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    for (final entry in _ingredients) {
      entry.dispose();
    }
    super.dispose();
  }

  void _addEmptyIngredient() {
    setState(() {
      _ingredients.add(_IngredientEntry(
        nameController: TextEditingController(),
        amountController: TextEditingController(),
        unitController: TextEditingController(text: 'g'),
      ));
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients[index].dispose();
      _ingredients.removeAt(index);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final validIngredients = _ingredients
        .where((e) =>
            e.nameController.text.trim().isNotEmpty &&
            (double.tryParse(e.amountController.text) ?? 0) > 0)
        .toList();

    if (validIngredients.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('材料を2つ以上入力してください')),
      );
      return;
    }

    final ingredients = validIngredients.map((e) {
      final amount = double.parse(e.amountController.text);
      if (e.id != null) {
        return IngredientItem(
          id: e.id!,
          name: e.nameController.text.trim(),
          baseAmount: amount,
          currentAmount: amount,
          unit: e.unitController.text.trim().isEmpty
              ? 'g'
              : e.unitController.text.trim(),
        );
      }
      return IngredientItem.create(
        name: e.nameController.text.trim(),
        baseAmount: amount,
        unit: e.unitController.text.trim().isEmpty
            ? 'g'
            : e.unitController.text.trim(),
      );
    }).toList();

    final notifier = ref.read(recipeListProvider.notifier);
    if (_isEditing) {
      await notifier.updateRecipe(widget.existingRecipe!.copyWith(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        ingredients: ingredients,
      ));
    } else {
      await notifier.addRecipe(MasterRecipe.create(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        ingredients: ingredients,
      ));
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'レシピ編集' : 'レシピ作成'),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('保存'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'レシピ名 *',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'レシピ名を入力してください' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '説明（任意）',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('材料', style: Theme.of(context).textTheme.titleMedium),
                TextButton.icon(
                  onPressed: _addEmptyIngredient,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('追加'),
                ),
              ],
            ),
            const Divider(),
            ..._ingredients.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: item.nameController,
                        decoration: const InputDecoration(
                          hintText: '材料名',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: item.amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[\d.]')),
                        ],
                        decoration: const InputDecoration(
                          hintText: '量',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 50,
                      child: TextFormField(
                        controller: item.unitController,
                        decoration: const InputDecoration(
                          hintText: '単位',
                          isDense: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, size: 20),
                      onPressed: _ingredients.length > 1
                          ? () => _removeIngredient(index)
                          : null,
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _IngredientEntry {
  final String? id;
  final TextEditingController nameController;
  final TextEditingController amountController;
  final TextEditingController unitController;

  _IngredientEntry({
    this.id,
    required this.nameController,
    required this.amountController,
    required this.unitController,
  });

  void dispose() {
    nameController.dispose();
    amountController.dispose();
    unitController.dispose();
  }
}
