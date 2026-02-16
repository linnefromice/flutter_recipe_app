import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_recipe_app/main.dart';

void main() {
  testWidgets('App launches and shows recipe list', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pump();

    // AppBar title is visible even during async loading
    expect(find.text('レシピ一覧'), findsOneWidget);
  });
}
