# Codex CLI コマンド

Codex: PATH 上の `codex` を自動解決する (`@openai/codex` npm 版を推奨)
未インストール時は `npm i -g @openai/codex`
ラッパースクリプト: `./.claude/skills/codex/codex.sh`

## トラブルシュート
| 症状 | 対応 |
|------|------|
| `codex コマンドが見つかりません` | `command -v codex` でパスを確認。PATH に無ければ `npm i -g @openai/codex` |
| `codex の最終回答が空でした` | レート制限 / セッション切れの可能性。スクリプトが自動で最大3回リトライする |
| `codex が異常終了しました` | 自動リトライされる。認証切れが原因なら `codex login` 後に再実行 |
| `SKIP` が出力された | 3回連続の実行エラー。エラーログで原因（未ログイン等）を確認。環境を直して再実行するか、レビュー省略で続行 |

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
| SKIP | codex が3回連続で実行エラー（レビュー未実施） | レビュー省略で続行可。その旨をユーザーに報告する |
