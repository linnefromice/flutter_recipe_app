import 'package:flutter/material.dart';

import '../models/master_recipe.dart';

class RecipeCard extends StatelessWidget {
  final MasterRecipe recipe;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        title: Text(recipe.name,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          recipe.ingredients.map((i) => '${i.name} ${i.baseAmount}${i.unit}').join(', '),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: onDelete,
        ),
        onTap: onTap,
      ),
    );
  }
}
