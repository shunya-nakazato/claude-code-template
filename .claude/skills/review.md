# Skill: 統合レビュー

## 概要
型チェック、Prettierチェック、Codexレビューを一括実行する統合レビュースキル。

## トリガー
ユーザーが `/review` を実行した時

## フロー
1. Docker内で型チェック実行
   ./.claude/scripts/test.sh type-check

2. Docker内でlint実行（Prettier含む）
   ./.claude/scripts/test.sh lint

3. エラーがあれば修正し、Step 1から再実行

4. インポートパス検証
   - 変更ファイルのインポートパスがcode-rule.mdのエイリアス定義に準拠しているか確認

5. Codexレビュー実行
   - 直近のplan.mdが存在する場合、planに沿った実装かレビュー
   - plan.mdが存在しない場合、一般的なコード品質レビュー

6. Codex結果がFAILの場合、指摘事項を修正しStep 1から再実行

7. PASSが出たらユーザーに結果を報告

## 自動ループ
- Step 1-6を最大3回繰り返す
- 3回でPASSしない場合はユーザーに報告して中断

## 禁止事項
- Codex指摘の無視
- Docker外でのフォーマッター実行
