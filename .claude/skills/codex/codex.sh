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

# PATH 上の codex を優先し、見つからない場合のみ既知の絶対パスを順に試す
# (旧 Caskroom 版を直指ししないことで npm/nvm 経由の最新版を使えるようにする)
resolve_codex() {
    if command -v codex >/dev/null 2>&1; then
        command -v codex
        return 0
    fi
    for candidate in \
        "$HOME/.nvm/versions/node/$(node --version 2>/dev/null | tr -d 'v')/bin/codex" \
        "/usr/local/bin/codex" \
        "/opt/homebrew/bin/codex"
    do
        if [ -x "$candidate" ]; then
            echo "$candidate"
            return 0
        fi
    done
    return 1
}

CODEX="$(resolve_codex || true)"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../.." && pwd)"
PLANS_DIR="$PROJECT_ROOT/.claude/plans"

# リトライ設定
MAX_RETRIES=3
RETRY_WAIT=5

# ヘルパー関数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# codex コマンドの存在確認
check_codex() {
    if [ -z "$CODEX" ] || [ ! -x "$CODEX" ]; then
        log_error "codex コマンドが見つかりません (PATH / 既知パスを探索)"
        log_error "  PATH=$PATH"
        log_error "  npm 版の場合: npm i -g @openai/codex"
        exit 1
    fi
    log_info "codex 解決先: $CODEX"
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

# codex を実行し、--output-last-message で受けた最終回答のみを検証する
# (進捗ログと最終回答の混在による誤判定を避けるため、判定対象をファイルに分離する)
# 使い方: run_codex_capture <検証モード go|review> <codexコマンド...>
#   go:     最終回答が非空 かつ 単語として GO または FAIL を含めば成功
#   review: 最終回答が非空なら成功 (review は GO/FAIL を出力しない仕様)
run_codex_capture() {
    local mode="$1"
    shift
    local last_msg
    last_msg=$(mktemp)
    local exit_code=0

    # stderr は分離せず stdout と統合して見せる (Codex 進捗ログを失わないため)
    if "$@" --output-last-message "$last_msg" 2>&1; then
        exit_code=0
    else
        exit_code=$?
    fi

    if [ "$exit_code" -ne 0 ]; then
        log_error "codex が異常終了しました (exit=$exit_code)"
        rm -f "$last_msg"
        return "$exit_code"
    fi

    if [ ! -s "$last_msg" ]; then
        log_error "codex の最終回答が空でした"
        rm -f "$last_msg"
        return 1
    fi

    if [ "$mode" = "go" ] && ! grep -qw -e GO -e FAIL "$last_msg"; then
        log_error "codex の最終回答に GO/FAIL マーカーが含まれていません"
        rm -f "$last_msg"
        return 1
    fi

    rm -f "$last_msg"
    return 0
}

# codex 実行エラー時に最大 MAX_RETRIES 回試行し、全滅した場合は SKIP を出力して正常終了する
# (レビュー待ちで作業全体がブロックされるのを防ぐ。SKIP は「レビュー省略で続行可」の意)
# 使い方: run_with_retry <検証モード go|review> <codexコマンド...>
run_with_retry() {
    local attempt
    for attempt in $(seq 1 "$MAX_RETRIES"); do
        if run_codex_capture "$@"; then
            return 0
        fi
        log_error "codex 実行エラー ($attempt/$MAX_RETRIES)"
        if [ "$attempt" -lt "$MAX_RETRIES" ]; then
            sleep "$RETRY_WAIT"
        fi
    done

    log_warn "codex が${MAX_RETRIES}回連続でエラーになったためレビューをスキップします"
    log_warn "エラー内容は上記ログを確認してください (未ログイン等の環境問題の場合は codex login 後に再実行)"
    echo "SKIP"
    return 0
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

    run_with_retry go "$CODEX" exec "以下のplan.mdをレビューしてください。

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
    run_with_retry review "$CODEX" exec review "指摘は致命的な欠陥やセキュリティホールなど重要度が中〜高のものに限定してください。軽微なスタイルや好みの問題は指摘不要です。"
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
