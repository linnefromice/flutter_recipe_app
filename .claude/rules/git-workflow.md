---
description: "Git ワークフローとコミット規約"
---

# Git ワークフロー

## コミットメッセージ形式

```
<type>: <description>

<optional body>
```

Types: feat, fix, refactor, docs, test, chore, perf, ci

## 機能実装ワークフロー

1. **まず計画** — `planner` エージェントで計画作成
2. **TDDアプローチ** — テストを先に書き、実装、リファクタ
3. **コードレビュー** — `code-reviewer` エージェントで品質確認
4. **ドキュメント更新** — `docs/` の関連ドキュメントを同期
5. **検証** — `flutter analyze && flutter test` で最終確認
6. **コミット** — Conventional Commits 形式で詳細なメッセージ

## PR ワークフロー

1. 全コミット履歴を分析（最新だけでなく）
2. `git diff main...HEAD` で全変更を確認
3. 包括的な PR サマリーを作成
4. テスト計画を記載
