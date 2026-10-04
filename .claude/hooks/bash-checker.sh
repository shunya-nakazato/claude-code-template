#!/bin/bash
# 絶対パス・危険なコマンド・専用ツールで代替可能なコマンドを検出する補助ガード。
# パターン検査にすぎず、セキュリティ境界としては使えない。
# コマンドは printf '%s' で渡す（echo は -e/-n/バックスラッシュを解釈し、検出が漏れうる）

COMMAND=$(jq -r '.tool_input.command // ""')

# ----- 1. 絶対パスチェック -----
# 除外パターンを取り除く（/dev/null, シバン行等）
FILTERED=$(printf '%s' "$COMMAND" | sed \
  -e 's|/dev/null||g' \
  -e 's|/dev/stderr||g' \
  -e 's|/dev/stdout||g' \
  -e 's|#!/[^ ]*||g' \
)

if printf '%s' "$FILTERED" | grep -qE '(^|[ "'"'"'=])/(Users|home|tmp|var|etc|opt)/'; then
  echo '{"decision":"block","reason":"絶対パス検出: Bashコマンドでは相対パスを使用してください"}'
  exit 0
fi

# ----- 2. 危険なコマンドの検出 -----
if printf '%s' "$COMMAND" | grep -qE 'rm\s+([a-zA-Z-]*\s+)*(/|\.git|node_modules/\.\.|\$HOME|~)(/|\b)' \
   && printf '%s' "$COMMAND" | grep -qE 'rm\s+([a-zA-Z-]*\s+)*(-[a-zA-Z]*f|--force)'; then
  echo '{"decision":"block","reason":"危険なコマンド検出: 重要ディレクトリの強制削除は許可されていません"}'
  exit 0
fi

# git push --force / -f を main/master に対して検出（--force-with-lease 含む）
if printf '%s' "$COMMAND" | grep -qE 'git\s+push\b.*(--force(-with-lease)?|\s-f\b).*\b(main|master)\b' \
   || printf '%s' "$COMMAND" | grep -qE 'git\s+push\b.*\b(main|master)\b.*(--force(-with-lease)?|\s-f\b)'; then
  echo '{"decision":"block","reason":"危険なコマンド検出: main/masterへのforce pushは禁止されています"}'
  exit 0
fi

# git reset --hard の検出（警告のみ）
if printf '%s' "$COMMAND" | grep -qE 'git\s+reset\s+--hard'; then
  echo '{"decision":"warn","reason":"git reset --hard が検出されました。未コミットの変更が失われる可能性があります。本当に実行しますか？"}'
  exit 0
fi

# ----- 3. 専用ツールで代替可能なコマンドの検出 -----
# cat/head/tail でファイルを読む場合（リダイレクト・ヒアドキュメント・パイプ出力を除く）
if printf '%s' "$COMMAND" | grep -qE '^\s*(cat|head|tail)\s+\S+\s*$'; then
  echo '{"decision":"warn","reason":"ファイル読み取りにはReadツールの使用を推奨します（cat/head/tailではなく）"}'
  exit 0
fi

# grep/rg でファイル内容を検索する場合
if printf '%s' "$COMMAND" | grep -qE '^\s*(grep|rg)\s+'; then
  echo '{"decision":"warn","reason":"ファイル内容の検索にはGrepツールの使用を推奨します"}'
  exit 0
fi

# find でファイルを探す場合
if printf '%s' "$COMMAND" | grep -qE '^\s*find\s+'; then
  echo '{"decision":"warn","reason":"ファイル検索にはGlobツールの使用を推奨します"}'
  exit 0
fi

# sed/awk でファイルを編集する場合（-i フラグ付き = インプレース編集）
if printf '%s' "$COMMAND" | grep -qE '^\s*(sed\s+-[a-zA-Z]*i|awk\s+-i)'; then
  echo '{"decision":"warn","reason":"ファイル編集にはEditツールの使用を推奨します"}'
  exit 0
fi

# すべてのチェックを通過
echo '{}'
