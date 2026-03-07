# Claude Code Template

Claude Code を活用した開発プロジェクトのテンプレートリポジトリ。

## 始め方

1. このテンプレートからリポジトリを作成する
2. Claude Code を起動し `/setup` を実行する
3. 対話形式でプロジェクトのルール（技術スタック、コーディングスタイル等）を設定する
4. 設定が完了したら開発を開始する

## 構成の概要

- `CLAUDE.md` — Claude Code が参照するメインの設定ファイル
- `.claude/rules/` — プロジェクト全体の不変ルールを定義するファイル群
- `.claude/skills/` — ワークフローを自動化するスキル（`/commit`, `/plan-review` 等）
- `.claude/plans/` — タスクごとの詳細プラン
- `.claude/tasks/` — タスク一覧と学びの記録
- `docs/` — 開発中に成長するドキュメント
