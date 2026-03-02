import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/screens/recipe_editor_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/golden_test_helpers.dart';
import '../helpers/test_fixtures.dart';

void main() {
  group('RecipeEditorScreen Golden Tests', () {
    goldenTest(
      'renders correctly',
      fileName: 'recipe_editor_screen',
      tags: ['golden'],
      builder: () => GoldenTestGroup(
        columns: 1,
        columnWidthBuilder: (_) => const FixedColumnWidth(500),
        scenarioConstraints:
            const BoxConstraints(maxWidth: 500, maxHeight: 800),
        children: [
          GoldenTestScenario(
            name: 'create mode',
            child: GoldenTestApp(
              overrides: [
                recipeListOverride([]),
              ],
              child: const RecipeEditorScreen(),
            ),
          ),
          GoldenTestScenario(
            name: 'edit mode',
            child: GoldenTestApp(
              overrides: [
                recipeListOverride(TestFixtures.threeRecipes),
              ],
              child: RecipeEditorScreen(
                existingRecipe: TestFixtures.cookieRecipe,
              ),
            ),
          ),
        ],
      ),
    );
  });
}
