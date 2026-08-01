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

# ヘルパー関数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
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

# 出力を tee して stdout に流しつつ、空応答を検出する
# (codex exec が無音で終了するケースがあるため呼び出し側で検証する)
run_codex_capture() {
    local tmp
    tmp=$(mktemp)
    local exit_code=0

    # stderr は分離せず stdout と統合して見せる (Codex 進捗ログを失わないため)
    "$@" 2>&1 | tee "$tmp"
    exit_code=${PIPESTATUS[0]}

    if [ "$exit_code" -ne 0 ]; then
        log_error "codex が異常終了しました (exit=$exit_code)"
        rm -f "$tmp"
        return "$exit_code"
    fi

    # ファイルが空なら無音応答とみなす
    # (GO/FAIL マーカーの検証は plan-codex-error-skip で導入予定。現状は空チェックのみ)
    if [ ! -s "$tmp" ]; then
        log_error "codex の出力が空でした。再実行するか手動でレビューしてください"
        rm -f "$tmp"
        return 1
    fi

    rm -f "$tmp"
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

    run_codex_capture "$CODEX" exec "以下のplan.mdをレビューしてください。

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
    run_codex_capture "$CODEX" exec review "指摘は致命的な欠陥やセキュリティホールなど重要度が中〜高のものに限定してください。軽微なスタイルや好みの問題は指摘不要です。"
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
