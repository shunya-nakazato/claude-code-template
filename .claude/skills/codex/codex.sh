#!/bin/bash

# Codex CLI ラッパースクリプト
# codex コマンドのGO判定・コードレビューを簡易実行する
#
# 使用方法:
#   ./.claude/skills/codex/codex.sh go [plan-file]   # GO判定（plan.mdのレビュー）
#   ./.claude/skills/codex/codex.sh review           # コードレビュー
#
# 引数:
#   go    - planの承認判定
#           plan-file を指定しない場合、最新のplan-*.mdを使用
#   review - コードレビュー

set -e

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

CODEX="/usr/local/bin/codex"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
PLANS_DIR="$PROJECT_ROOT/.claude/plans"

# ヘルパー関数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# codex コマンドの存在確認
check_codex() {
    if [ ! -x "$CODEX" ]; then
        log_error "codex コマンドが見つかりません: $CODEX"
        exit 1
    fi
}

# 最新のplanファイルを取得
get_latest_plan() {
    local latest
    latest=$(ls -t "$PLANS_DIR"/plan-*.md 2>/dev/null | head -1)
    if [ -z "$latest" ]; then
        log_error "planファイルが見つかりません: $PLANS_DIR/plan-*.md"
        exit 1
    fi
    echo "$latest"
}

# GO判定: planのレビュー
run_go() {
    local plan_file="${1:-$(get_latest_plan)}"

    if [ ! -f "$plan_file" ]; then
        log_error "planファイルが存在しません: $plan_file"
        exit 1
    fi

    log_info "GO判定を実行: $plan_file"

    local plan_content
    plan_content=$(cat "$plan_file")

    $CODEX exec "以下のplan.mdをレビューしてください。

レビュー基準:
- 致命的なバグ、セキュリティホール、データ損失リスクのみ指摘する
- エッジケースの網羅性、設計の好み、コードスタイルは指摘不要
- 実装が動作し、主要なユースケースをカバーしていれば GO とする
- 完璧さではなく実用性を重視する

問題なければ GO、致命的な問題があれば FAIL と修正点を返答。

$plan_content"
}

# コードレビュー
run_review() {
    log_info "コードレビューを実行"
    $CODEX exec review "指摘は致命的な欠陥やセキュリティホールなど重要度が中〜高のものに限定してください。軽微なスタイルや好みの問題は指摘不要です。"
}

# 使用方法を表示
usage() {
    echo "使用方法: $0 <command> [options]"
    echo ""
    echo "コマンド:"
    echo "  go [plan-file]  GO判定（plan.mdのレビュー）"
    echo "  review          コードレビュー"
    exit 1
}

# メイン処理
main() {
    local command="${1:-}"

    if [ -z "$command" ]; then
        usage
    fi

    check_codex

    shift
    case "$command" in
        go)
            run_go "$@"
            ;;
        review)
            run_review
            ;;
        *)
            log_error "不明なコマンド: $command"
            usage
            ;;
    esac
}

main "$@"
