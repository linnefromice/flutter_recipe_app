import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_recipe_app/screens/calculator_screen.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/golden_test_helpers.dart';
import '../helpers/test_fixtures.dart';

void main() {
  group('CalculatorScreen Golden Tests', () {
    goldenTest(
      'renders correctly',
      fileName: 'calculator_screen',
      tags: ['golden'],
      builder: () => GoldenTestGroup(
        columns: 1,
        columnWidthBuilder: (_) => const FixedColumnWidth(500),
        scenarioConstraints:
            const BoxConstraints(maxWidth: 500, maxHeight: 800),
        children: [
          GoldenTestScenario(
            name: 'initial state (x1.00)',
            child: GoldenTestApp(
              overrides: [
                calculatorOverrides({
                  'recipe-001': TestFixtures.calculatorInitialState,
                }),
              ],
              child: CalculatorScreen(recipe: TestFixtures.cookieRecipe),
            ),
          ),
          GoldenTestScenario(
            name: 'adjusted (x1.50)',
            child: GoldenTestApp(
              overrides: [
                calculatorOverrides({
                  'recipe-001': TestFixtures.calculatorAdjustedState,
                }),
              ],
              child: CalculatorScreen(recipe: TestFixtures.cookieRecipe),
            ),
          ),
        ],
      ),
    );
  });
}
