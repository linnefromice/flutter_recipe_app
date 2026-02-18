---
description: "包括的な検証を実行する"
---

# Verify

プロジェクトの包括的な検証を実行してください。

## 検証フェーズ

### 1. 静的解析
```bash
flutter analyze
```

### 2. テスト
```bash
flutter test
```

### 3. print() 監査
変更ファイル内に print() / debugPrint() が残っていないか確認。

### 4. Git 状態
```bash
git status
git diff --stat
```

## 出力形式

```
検証レポート
==================

静的解析:  [PASS/FAIL] (Xエラー, Y警告)
テスト:    [PASS/FAIL] (X/Y合格)
print監査: [PASS/FAIL] (X件検出)
Git状態:   [X files changed]

総合:      [OK / 要修正]

修正すべき問題:
1. ...
```
