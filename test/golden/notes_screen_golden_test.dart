import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/screens/notes_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/golden_test_helpers.dart';
import '../helpers/test_fixtures.dart';

void main() {
  group('NotesScreen Golden Tests', () {
    goldenTest(
      'renders correctly',
      fileName: 'notes_screen',
      tags: ['golden'],
      builder: () => GoldenTestGroup(
        columns: 1,
        columnWidthBuilder: (_) => const FixedColumnWidth(500),
        scenarioConstraints:
            const BoxConstraints(maxWidth: 500, maxHeight: 800),
        children: [
          GoldenTestScenario(
            name: 'empty notes',
            child: GoldenTestApp(
              overrides: [
                notesOverrides({'recipe-001': []}),
              ],
              child: const NotesScreen(
                recipeId: 'recipe-001',
                recipeName: 'クッキー',
              ),
            ),
          ),
          GoldenTestScenario(
            name: 'with 2 notes',
            child: GoldenTestApp(
              overrides: [
                notesOverrides({'recipe-001': TestFixtures.twoNotes}),
              ],
              child: const NotesScreen(
                recipeId: 'recipe-001',
                recipeName: 'クッキー',
              ),
            ),
          ),
        ],
      ),
    );
  });
}
