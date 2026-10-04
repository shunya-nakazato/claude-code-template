#!/bin/bash
# セッション開始時に、git の hook の置き場所（core.hooksPath）を .claude/git-hooks に向ける。
# 既に別の値があれば、他の hook の仕組みを壊さないよう変えずに警告だけ出す。
# セッションの開始を止めないよう、常に exit 0 で終える

git rev-parse --git-dir >/dev/null 2>&1 || exit 0
[ -d .claude/git-hooks ] || exit 0

current=$(git config --get core.hooksPath)
if [ -z "$current" ]; then
  git config core.hooksPath .claude/git-hooks \
    || echo "core.hooksPath を設定できませんでした。commit 前の gitleaks 検査が走りません。" >&2
elif [ "$current" != ".claude/git-hooks" ]; then
  echo "core.hooksPath が ${current} に設定されているため、.claude/git-hooks の gitleaks 検査は走りません。" >&2
fi
exit 0
