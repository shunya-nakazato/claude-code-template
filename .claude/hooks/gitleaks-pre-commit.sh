#!/bin/bash
# git commit 前に staged 変更を gitleaks で検査し、秘密情報があればブロックする。
# 対象の判定は settings.json の "if" ではなくここで行う（"if" が効かない環境があり、前方一致では git -C も漏れる）。
# オプションは gitleaks 公式 pre-commit フック定義（.pre-commit-hooks.yaml）と同一
set -u

GITLEAKS_IMAGE="ghcr.io/gitleaks/gitleaks:v8.30.1"

# stdin: JSON { "tool_input": { "command": "..." } }
# commit が git のサブコマンドのとき（git とのあいだにオプションだけを挟む形）を対象にする。
# 文字列の中の "git commit" や、同じ行の別の git コマンドでは止めない。macOS の grep / sed は \b を解釈しない
COMMAND=$(jq -r '.tool_input.command // ""')
GIT_COMMIT_RE="(^|[;&|(\`[:space:]])git(([[:space:]]+-[Cc][[:space:]]+(\"[^\"]*\"|'[^']*'|[^[:space:]]+))|([[:space:]]+--?[A-Za-z][^[:space:]]*))*[[:space:]]+commit([[:space:]]|$)"
invocation=$(printf '%s' "$COMMAND" | grep -oE "$GIT_COMMIT_RE" | head -1)
if [ -z "$invocation" ]; then
  exit 0
fi

# git -C <dir> commit はカレントディレクトリではなく <dir> の staged を検査する
target="$PWD"
dir=$(printf '%s' "$invocation" | sed -nE "s/.*[[:space:]]-C[[:space:]]+(\"[^\"]*\"|'[^']*'|[^[:space:]]+).*/\1/p")
if [ -n "$dir" ]; then
  dir="${dir%\"}"; dir="${dir#\"}"; dir="${dir%\'}"; dir="${dir#\'}"
  if ! target=$(cd "$dir" 2>/dev/null && pwd); then
    echo "git -C の対象ディレクトリ（${dir}）を解決できないため、gitleaks で検査できません。変数を使わないパスで commit してください。" >&2
    exit 2
  fi
fi

if ! docker info >/dev/null 2>&1; then
  echo "Docker が起動していないため gitleaks スキャンを実行できません。Docker を起動してから再度 commit してください。" >&2
  exit 2
fi

output=$(docker run --rm -v "$target:/scan" "$GITLEAKS_IMAGE" \
  git --pre-commit --redact --staged --verbose /scan 2>&1)
status=$?

if [ $status -ne 0 ]; then
  # bash 3.2 は $status 直後の全角文字を変数名に含めて解釈するため ${} で明示する
  echo "gitleaks スキャンが失敗しました（exit=${status}）。秘密情報の検出または実行エラーのため commit をブロックします。" >&2
  echo "$output" | tail -40 >&2
  exit 2
fi

exit 0
