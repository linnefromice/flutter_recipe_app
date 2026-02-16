# Flutter Recipe Calculator

特定の材料の量を指定すると、基準比率を維持したまま他の全材料を自動計算するアプリ。

「小麦粉が135g余っている → それに合わせて全材料を再計算」というニーズに応えます。

## 機能

- **レシピ管理** - レシピの作成・編集・削除
- **ライブ計算** - 任意の材料の量を変更すると、他の全材料がリアルタイムに再計算される
- **倍率表示** - 基準量に対する現在の倍率を表示（例: x1.35）
- **調整記録** - 計算結果をメモ付きで保存・履歴表示

## Tech Stack

- **Flutter** (Dart)
- **flutter_riverpod** - 状態管理
- **shared_preferences** - ローカルストレージ（JSON）
- **uuid** - ID生成
- **intl** - 日付フォーマット

## プロジェクト構成

```
lib/
├── main.dart
├── models/          # Immutable データモデル
├── providers/       # Riverpod 状態管理
├── services/        # 計算ロジック・永続化
├── screens/         # 画面（一覧・編集・計算・記録）
└── widgets/         # 再利用可能なUIコンポーネント
```

## セットアップ

```bash
flutter pub get
flutter run
```

## テスト

```bash
flutter test
```
