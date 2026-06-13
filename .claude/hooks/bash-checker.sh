#!/bin/bash
# Bashコマンドの汎用チェッカー
# stdin: JSON { "tool_input": { "command": "..." } }
#
# チェック項目:
# 1. 絶対パスの検出
# 2. 危険なコマンドの検出
# 3. 専用ツールで代替可能なコマンドの検出
#
# 【重要】このフックは補助的なガードレールであり、完全なセキュリティ境界ではない。
#   パターンマッチ方式のため、変数展開・base64・コマンド分割・別名コマンド等で
#   容易に回避できる。事故の「うっかり」を減らす目的であり、悪意ある操作や
#   信頼できないコマンドの実行に対する防御として依存してはならない。
#
# 注: コマンド文字列は printf '%s' で各検査に渡す。echo は -e/-n/バックスラッシュを
#     解釈しうるため、危険コマンド検出の偽陰性につながる。

COMMAND=$(jq -r '.tool_input.command // ""')

# ----- 1. 絶対パスチェック -----
# 除外パターンを取り除く（/dev/null, シバン行 等）
FILTERED=$(printf '%s' "$COMMAND" | sed \
  -e 's|/dev/null||g' \
  -e 's|/dev/stderr||g' \
  -e 's|/dev/stdout||g' \
  -e 's|#!/[^ ]*||g' \
)

if printf '%s' "$FILTERED" | grep -qE '(^|[ "'"'"'=])/(Users|home|tmp|var|etc|opt)/'; then
  echo '{"decision":"block","reason":"絶対パス検出: Bashコマンドでは相対パスを使用してください（lessons.md #4）"}'
  exit 0
fi

# ----- 2. 危険なコマンドの検出 -----
# rm による重要ディレクトリの強制削除を検出する。
#   - -f/-r はフラグ順・分割（-rf / -fr / -r -f）・--force を網羅する
#   - 削除対象は / (ルート) / .git / node_modules/.. / $HOME / ~ を対象とする
# （パターン回避は可能。冒頭コメントの通り境界防御ではない点に注意）
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
