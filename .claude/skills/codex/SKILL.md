# Codex CLI コマンド

Codex: `/usr/local/bin/codex`
ラッパースクリプト: `./.claude/scripts/codex.sh`

## 基本コマンド
```bash
./.claude/scripts/codex.sh review           # コードレビュー
./.claude/scripts/codex.sh go [plan-file]   # GO判定（planレビュー）
./.claude/scripts/codex.sh pass             # PASS判定（最終確認）
```

## GO判定 (Phase 1完了時)
```bash
# 最新のplanファイルを自動検出してレビュー
./.claude/scripts/codex.sh go

# 特定のplanファイルを指定してレビュー
./.claude/scripts/codex.sh go .claude/plans/plan-XXXXXXXX.md
```

## PASS判定 (Phase 2完了時)
```bash
./.claude/scripts/codex.sh pass
```

## 判定結果
| 結果 | 意味 | 次のアクション |
|------|------|--------------|
| GO | plan承認 | Phase 2へ、実装開始 |
| PASS | 実装承認 | Phase 3へ |
| FAIL | 要修正 | フィードバックに従い修正 |
