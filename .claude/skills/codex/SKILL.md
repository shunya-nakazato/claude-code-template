# Codex CLI コマンド

Codex: PATH 上の `codex` を自動解決する (`@openai/codex` npm 版を推奨)
未インストール時は `npm i -g @openai/codex`
ラッパースクリプト: `./.claude/skills/codex/codex.sh`

## トラブルシュート
| 症状 | 対応 |
|------|------|
| `codex コマンドが見つかりません` | `command -v codex` でパスを確認。PATH に無ければ `npm i -g @openai/codex` |
| `codex の出力が空でした` | レート制限 / セッション切れの可能性。再実行するか手動レビューに切り替える |
| `codex が異常終了しました` | exit code を確認しログを再実行で取得。認証切れなら `codex login` |

## 基本コマンド
```bash
./.claude/skills/codex/codex.sh review           # コードレビュー
./.claude/skills/codex/codex.sh go [plan-file]   # GO判定（planレビュー）
```

## GO判定
```bash
# 最新のplanファイルを自動検出してレビュー
./.claude/skills/codex/codex.sh go

# 特定のplanファイルを指定してレビュー
./.claude/skills/codex/codex.sh go .claude/plans/plan-XXXXXXXX.md
```

## 判定結果
| 結果 | 意味 | 次のアクション |
|------|------|--------------|
| GO | plan承認 | 実装開始 |
| FAIL | 要修正 | フィードバックに従い修正 |
