import 'package:flutter/material.dart';

import '../models/master_recipe.dart';

class RecipeCard extends StatelessWidget {
  final MasterRecipe recipe;
  final int noteCount;
  final VoidCallback onTap;
  final VoidCallback onNotesPressed;
  final VoidCallback onDelete;

  const RecipeCard({
    super.key,
    required this.recipe,
    this.noteCount = 0,
    required this.onTap,
    required this.onNotesPressed,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        title: Text(recipe.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          recipe.ingredients
              .map((i) => '${i.name} ${i.baseAmount}${i.unit}')
              .join(', '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (noteCount > 0)
              IconButton(
                icon: Badge(
                  label: Text('$noteCount'),
                  child: Icon(Icons.history,
                      color: theme.colorScheme.primary),
                ),
                tooltip: '記録 ($noteCount件)',
                onPressed: onNotesPressed,
              )
            else
              IconButton(
                icon: const Icon(Icons.history, color: Colors.grey),
                tooltip: '記録なし',
                onPressed: onNotesPressed,
              ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: onDelete,
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
