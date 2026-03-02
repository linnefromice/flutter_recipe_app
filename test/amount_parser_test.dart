import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_recipe_app/utils/amount_parser.dart';

void main() {
  group('parseAmount', () {
    test('整数文字列をパースできる', () {
      expect(parseAmount('100'), 100.0);
    });

    test('小数点付き文字列をパースできる', () {
      expect(parseAmount('3.14'), 3.14);
    });

    test('カンマを小数点として扱う', () {
      expect(parseAmount('3,14'), 3.14);
    });

    test('ゼロは null を返す', () {
      expect(parseAmount('0'), isNull);
    });

    test('負の値は null を返す', () {
      expect(parseAmount('-5'), isNull);
    });

    test('空文字列は null を返す', () {
      expect(parseAmount(''), isNull);
    });

    test('数値でない文字列は null を返す', () {
      expect(parseAmount('abc'), isNull);
    });

    test('複数カンマは全て置換される', () {
      // '1,000,5' → '1.000.5' → double.tryParse fails → null
      expect(parseAmount('1,000,5'), isNull);
    });

    test('正の小数値を正しくパースする', () {
      expect(parseAmount('0.5'), 0.5);
    });

    test('カンマのみの小数値をパースする', () {
      expect(parseAmount('0,5'), 0.5);
    });
  });
}
