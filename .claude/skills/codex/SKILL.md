# Codex CLI コマンド

Codex: `/usr/local/bin/codex`
ラッパースクリプト: `./.claude/skills/codex/codex.sh`

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
