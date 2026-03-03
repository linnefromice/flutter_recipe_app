import 'package:flutter/material.dart';

import '../models/master_recipe.dart';

class RecipeCard extends StatelessWidget {
  final MasterRecipe recipe;
  final int noteCount;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onNotesPressed;
  final VoidCallback onDelete;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onDuplicate;

  const RecipeCard({
    super.key,
    required this.recipe,
    this.noteCount = 0,
    required this.onTap,
    required this.onEdit,
    required this.onNotesPressed,
    required this.onDelete,
    this.onToggleFavorite,
    this.onDuplicate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: IconButton(
          icon: Icon(
            recipe.isFavorite ? Icons.star : Icons.star_border,
            color: recipe.isFavorite ? Colors.amber : Colors.grey,
          ),
          tooltip: recipe.isFavorite ? 'お気に入り解除' : 'お気に入り',
          onPressed: onToggleFavorite,
        ),
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
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    onEdit();
                  case 'duplicate':
                    onDuplicate?.call();
                  case 'delete':
                    onDelete();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit_outlined),
                    title: Text('編集'),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'duplicate',
                  child: ListTile(
                    leading: Icon(Icons.copy),
                    title: Text('複製'),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete_outline, color: Colors.red),
                    title: Text('削除', style: TextStyle(color: Colors.red)),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
