---
name: verification-loop
description: "包括的な検証システム。機能完了後やPR作成前に使用。ビルド、テスト、静的解析、セキュリティスキャンを一括で実行。"
---

# Verification Loop

機能完了後やPR作成前に実行する包括的な検証システム。

---

## 検証フェーズ

### Phase 1: 静的解析
```bash
flutter analyze 2>&1 | head -30
```
エラーがあれば続行前に修正。

### Phase 2: テストスイート
```bash
flutter test 2>&1
```
レポート:
- 総テスト数
- 合格 / 不合格
- 失敗テストの詳細

### Phase 3: print() 監査
変更ファイル内の `print()` / `debugPrint()` を検出:
```bash
git diff --name-only | xargs grep -n 'print(' 2>/dev/null
```

### Phase 4: 差分レビュー
```bash
git diff --stat
git diff --name-only
```
各変更ファイルを確認:
- 意図しない変更がないか
- デバッグコードが残っていないか
- ドキュメント更新が必要か

---

## 出力フォーマット

```
検証レポート
==================

静的解析:  [PASS/FAIL] (Xエラー, Y警告)
テスト:    [PASS/FAIL] (X/Y合格)
print監査: [PASS/FAIL] (X件検出)
差分:      [Xファイル変更]

総合:      PR [準備完了/未完了]

修正すべき問題:
1. ...
2. ...
```

---

## 使用タイミング

- 機能完了後
- PR 作成前
- リファクタリング後
- 大きな変更の後（15分ごとまたは変更チャンクごと）
