#!/bin/bash

# Codex CLI でプランの GO 判定とコードレビューを行うラッパー。
# Usage: codex.sh go [plan-file] | codex.sh review

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

# 1回の試行の上限 [秒]。codex がハングしたとき、これが無いとリトライも SKIP も発火しない
# (判定はすべて codex の終了を待つため)。既定 180s は実測 8s の20倍で、
# MAX_RETRIES 回すべて時間切れになっても 3 * (180+5+5) = 570s と呼び出し側の上限 600s に収まる
CODEX_TIMEOUT_S="${CODEX_TIMEOUT_S:-180}"
# TERM から KILL までの猶予 [秒]
KILL_GRACE_S=5
# coreutils の timeout(1) に合わせる
TIMEOUT_EXIT_CODE=124

# ヘルパー関数
# ログは stderr へ出す。stdout へ書くと、コマンド置換の中で呼んだときに
# 画面に出ないまま値として捕まる (get_latest_plan がこれで壊れていた)
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1" >&2
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
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
    # プラン名は plan-<YYYYMMDDTHHmmssZ>-<slug>.md。-t は「いま書いているプラン」を拾う意図
    latest=$(ls -t "$PLANS_DIR"/plan-*.md 2>/dev/null | head -1)
    if [ -z "$latest" ]; then
        log_error "planファイルが見つかりません: $PLANS_DIR/plan-*.md"
        exit 1
    fi
    echo "$latest"
}

# タイムアウト付きで実行する。macOS には timeout(1) が無いため自前で見張る。
# 戻り値: コマンドの終了コード。時間切れなら TIMEOUT_EXIT_CODE
run_with_timeout() {
    local seconds="$1"
    shift
    local marker
    marker=$(mktemp)

    # 本体も見張り役も、子孫ごと止められるよう専用のプロセスグループで起動する
    # (bash はジョブ制御が有効なときだけバックグラウンドジョブに新しい pgid を与える)
    set -m
    "$@" &
    local cmd_pid=$!

    (
        sleep "$seconds"
        kill -0 "$cmd_pid" 2>/dev/null || exit 0
        # 中身を書く。空ファイルだと [ -s ] が常に偽になり時間切れを検出できない
        printf 'timeout\n' > "$marker"
        kill -TERM "-$cmd_pid" 2>/dev/null   # 負の PID = プロセスグループ全体
        sleep "$KILL_GRACE_S"
        kill -KILL "-$cmd_pid" 2>/dev/null
    ) &
    local watchdog_pid=$!
    set +m

    local exit_code=0
    wait "$cmd_pid" || exit_code=$?

    if [ -s "$marker" ]; then
        # 本体が TERM で落ちても TERM を無視する子は残る。
        # 見張り役の KILL まで待ってから戻る (残したまま次の試行を始めない)
        wait "$watchdog_pid" 2>/dev/null || true
        exit_code="$TIMEOUT_EXIT_CODE"
    else
        # 見張り役だけを殺すと内側の sleep が残り、継承した stdout を
        # タイムアウトぶん握り続ける (パイプ越しの呼び出し側がそこで止まる)
        kill -TERM "-$watchdog_pid" 2>/dev/null || true
        wait "$watchdog_pid" 2>/dev/null || true
    fi

    rm -f "$marker"
    return "$exit_code"
}

run_codex_capture() {
    local mode="$1"
    shift
    local last_msg
    last_msg=$(mktemp)
    local exit_code=0

    # stderr は分離せず stdout と統合して見せる (Codex 進捗ログを失わないため)
    if run_with_timeout "$CODEX_TIMEOUT_S" "$@" --output-last-message "$last_msg" 2>&1; then
        exit_code=0
    else
        exit_code=$?
    fi

    if [ "$exit_code" -eq "$TIMEOUT_EXIT_CODE" ]; then
        log_error "codex が ${CODEX_TIMEOUT_S}s 応答しなかったため打ち切りました (CODEX_TIMEOUT_S で変更できる)"
        rm -f "$last_msg"
        return "$exit_code"
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
    local plan_file="$1"

    # 置換の中では exit がサブシェルしか止めないため、終了コードを親で受ける
    if [ -z "$plan_file" ]; then
        plan_file=$(get_latest_plan) || exit 1
    fi

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
