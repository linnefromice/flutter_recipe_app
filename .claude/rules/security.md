---
description: "セキュリティガイドライン"
globs: "lib/**/*.dart"
---

# セキュリティガイドライン

## コミット前チェック

- [ ] ハードコードされたシークレットがない（APIキー、パスワード、トークン）
- [ ] すべてのユーザー入力がバリデートされている
- [ ] エラーメッセージが機密データを漏洩しない
- [ ] print() でセンシティブな情報を出力していない

## 入力バリデーション

ユーザー入力は必ずバリデート:

```dart
// 数値入力のバリデーション
double? parseAmount(String input) {
  final value = double.tryParse(input);
  if (value == null || value < 0) return null;
  return value;
}
```

## データ永続化

- SharedPreferences はセンシティブでないデータのみ
- JSON シリアライズ時にデータの完全性を確認
- デシリアライズ時のエラーハンドリング
