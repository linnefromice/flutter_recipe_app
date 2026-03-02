import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/screens/recipe_list_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/golden_test_helpers.dart';
import '../helpers/test_fixtures.dart';

void main() {
  group('RecipeListScreen Golden Tests', () {
    goldenTest(
      'renders correctly',
      fileName: 'recipe_list_screen',
      tags: ['golden'],
      builder: () => GoldenTestGroup(
        columns: 1,
        columnWidthBuilder: (_) => const FixedColumnWidth(500),
        scenarioConstraints:
            const BoxConstraints(maxWidth: 500, maxHeight: 800),
        children: [
          GoldenTestScenario(
            name: 'empty list',
            child: GoldenTestApp(
              overrides: [
                recipeListOverride([]),
                notesOverrides({}),
              ],
              child: const RecipeListScreen(),
            ),
          ),
          GoldenTestScenario(
            name: 'with 3 recipes',
            child: GoldenTestApp(
              overrides: [
                recipeListOverride(TestFixtures.threeRecipes),
                notesOverrides({
                  'recipe-001': TestFixtures.twoNotes,
                  'recipe-002': [],
                  'recipe-003': [],
                }),
              ],
              child: const RecipeListScreen(),
            ),
          ),
        ],
      ),
    );
  });
}
