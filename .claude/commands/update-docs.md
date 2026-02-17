---
description: "コード変更に伴うドキュメントを更新する"
---

# Update Docs

最近のコード変更に基づいて、ドキュメントを更新してください。

## 手順

1. `git diff --name-only` で変更ファイルを確認
2. 以下の影響判定に従いドキュメントを更新:

| 変更箇所 | 更新対象 |
|---------|---------|
| `lib/models/` | `docs/requirements.md`（データモデル）, `docs/architecture.md` |
| `lib/providers/` | `docs/architecture.md`（Provider設計） |
| `lib/screens/` | `docs/requirements.md`（画面仕様）, `docs/architecture.md`（画面追加時） |
| `lib/services/` | `docs/architecture.md`（データフロー） |

3. 既存のフォーマットとスタイルに合わせて更新
4. 日本語で記述

## ルール

- コードの実態とドキュメントを一致させる
- 不要な情報を追加しない
- 既存のドキュメント構造を維持する
