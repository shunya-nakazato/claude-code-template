# プロジェクトメモリ

## コア原則
- **シンプル第一**: 変更を最小限に。影響範囲を狭く。過剰設計しない
- **手を抜かない**: 根本原因を見つける。一時的な修正は避ける。シニアエンジニアの水準を保つ
- **自律的に動く**: バグレポートを受けたら自分で調査・修正する。ユーザーのコンテキスト切り替えをゼロにする

## ワークフロー

<important if="タスク開始時・コンテキスト復元後">
**タスク実行前に `.claude/tasks/lessons.md` を必ず読み込む**（スキップ厳禁）
</important>

<important if="実装に着手しようとしている時">
**全てのタスクは Planモードで開始する**（タスクの大小を問わない）。プランレビュー（`/plan-review`）で GO 判定が出るまで実装に着手しない
</important>

### タスク管理手順
1. `.claude/tasks/lessons.md` を読む
2. `.claude/tasks/todo.md` に計画を書く
3. `.claude/plans/` にプランを作成 → `/plan-review` で GO 判定を得る
4. 実装 → 進捗を随時マーク
5. 検証（テスト実行・差分確認）→ 完了マーク
6. 修正を受けたら `.claude/tasks/lessons.md` を更新

### サブエージェント戦略
- コンテキストを共有せずに実行できるタスクにはサブエージェントを積極活用
- 1エージェント = 1タスク。リサーチ・調査・並列分析に使う

### 検証
- 動作を証明できるまで完了としない
- 「スタッフエンジニアはこれを承認するか？」と自問する

---

## ルール参照

| # | カテゴリ | ファイル |
|---|---------|---------|
| 1 | プロジェクト概要 | @.claude/rules/project-info.md |
| 2 | 技術スタック | @.claude/rules/tech-stack.md |
| 3 | コーディングルール | @.claude/rules/code-rule.md |
| 4 | Git | @.claude/rules/git-rule.md |
| 5 | ビルド・デプロイ | @.claude/rules/cicd-rule.md |
| 6 | テスト | @.claude/rules/test-rule.md |
| 7 | セキュリティ | @.claude/rules/security-mgmt.md |
| 8 | プラン | @.claude/rules/plan-rule.md |
