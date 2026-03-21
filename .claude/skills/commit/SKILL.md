# Skill: コミットワークフロー

## 概要
conventional commit 形式でのコミットと、Codex レビューを組み合わせたワークフロー。

## トリガー
ユーザーが `/commit` を実行した時

## フロー
```
1. git diff --cached --stat で変更内容を確認

2. conventional commit メッセージを生成
   - type: feat / fix / refactor / chore / docs / style / test
   - scope: 変更対象のモジュール名
   - title: 簡潔な変更概要
   - body: 変更の詳細

3. ユーザーに確認を求める

4. 承認後コミット
```

## コミットメッセージフォーマット
```
<type>(<scope>): <title>

<body>
```

対応するプランファイルが存在する場合のみ、フッターに `Ref: plan-<識別子>.md` を追加する。

## 禁止事項
- 余計なフッター（`Generated with...`, `Co-Authored-By`等）は含めない
- 絵文字は使用しない
- ユーザー承認なしでコミットしない

## アトミックコミットモード

複数の論理グループの変更が混在している場合に使用する。

### フロー
1. `git diff --cached --stat` と `git diff --stat` で全変更を確認
2. 変更を論理グループに分類（機能追加、バグ修正、リファクタリング、設定変更 等）
3. 無関係な変更を検出した場合、ユーザーに警告
4. グループごとに:
   a. 該当ファイルのみステージング
   b. conventional commit メッセージを生成
   c. ユーザーに確認 → 承認後コミット

### 自動検出
`/commit` 実行時に複数の論理グループが検出された場合、アトミックコミットモードの使用を提案する。
