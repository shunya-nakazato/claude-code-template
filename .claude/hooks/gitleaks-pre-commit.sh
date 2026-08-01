#!/bin/bash
# git commit 実行前に gitleaks で staged 変更をスキャンし、秘密情報検出時は commit をブロックする
# オプションは gitleaks 公式 pre-commit フック定義（.pre-commit-hooks.yaml）と同一
set -u

GITLEAKS_IMAGE="ghcr.io/gitleaks/gitleaks:v8.30.1"

if ! docker info >/dev/null 2>&1; then
  echo "Docker が起動していないため gitleaks スキャンを実行できません。Docker を起動してから再度 commit してください。" >&2
  exit 2
fi

output=$(docker run --rm -v "$PWD:/scan" "$GITLEAKS_IMAGE" \
  git --pre-commit --redact --staged --verbose /scan 2>&1)
status=$?

if [ $status -ne 0 ]; then
  # bash 3.2 は $status 直後の全角文字を変数名に含めて解釈するため ${} で明示する
  echo "gitleaks スキャンが失敗しました（exit=${status}）。秘密情報の検出または実行エラーのため commit をブロックします。" >&2
  echo "$output" | tail -40 >&2
  exit 2
fi

exit 0
