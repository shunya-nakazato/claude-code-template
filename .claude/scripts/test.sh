#!/bin/bash

# テスト実行スクリプト
# Dockerコンテナ上でテストを実行する
#
# 使用方法:
#   ./.claude/scripts/test.sh [target]
#
# target:
#   all        - 全テスト実行（デフォルト）
#   frontend   - フロントエンドテストのみ
#   backend    - バックエンドテストのみ
#   lint       - Lintのみ
#   type-check - 型チェックのみ

set -e

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# 引数のデフォルト値
TARGET="${1:-all}"

# ヘルパー関数
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Dockerコンテナが起動しているか確認
check_containers() {
    if ! docker compose ps --status running | grep -q "frontend"; then
        log_warning "フロントエンドコンテナが起動していません。起動します..."
        docker compose up -d frontend
        sleep 5
    fi

    if ! docker compose ps --status running | grep -q "backend"; then
        log_warning "バックエンドコンテナが起動していません。起動します..."
        docker compose up -d backend
        sleep 5
    fi
}

# npm scriptが存在するかチェック
has_npm_script() {
    local container=$1
    local script=$2
    docker compose exec -T "$container" npm run "$script" --if-present 2>/dev/null
    return $?
}

# フロントエンドのテスト
run_frontend_tests() {
    log_info "フロントエンドテストを実行中..."

    # 型チェック
    log_info "  型チェック..."
    docker compose exec -T frontend npm run type-check

    # Lint
    log_info "  Lint..."
    docker compose exec -T frontend npm run lint

    # ユニットテスト（package.jsonにtestスクリプトがある場合のみ）
    log_info "  ユニットテスト確認..."
    if docker compose exec -T frontend npm pkg get scripts.test 2>/dev/null | grep -qv "{}"; then
        log_info "  ユニットテスト実行..."
        docker compose exec -T frontend npm run test
    else
        log_warning "  ユニットテストスクリプトが未設定（スキップ）"
    fi

    log_success "フロントエンドテスト完了"
}

# バックエンドのテスト
run_backend_tests() {
    log_info "バックエンドテストを実行中..."

    # 型チェック
    log_info "  型チェック..."
    docker compose exec -T backend npx tsc --noEmit

    # Lint（package.jsonにlintスクリプトがある場合のみ）
    log_info "  Lint確認..."
    if docker compose exec -T backend npm pkg get scripts.lint 2>/dev/null | grep -qv "{}"; then
        log_info "  Lint実行..."
        docker compose exec -T backend npm run lint
    else
        log_warning "  Lintスクリプトが未設定（スキップ）"
    fi

    # ユニットテスト（package.jsonにtestスクリプトがある場合のみ）
    log_info "  ユニットテスト確認..."
    if docker compose exec -T backend npm pkg get scripts.test 2>/dev/null | grep -qv "{}"; then
        log_info "  ユニットテスト実行..."
        docker compose exec -T backend npm run test
    else
        log_warning "  ユニットテストスクリプトが未設定（スキップ）"
    fi

    log_success "バックエンドテスト完了"
}

# Lintのみ
run_lint() {
    log_info "Lintを実行中..."

    log_info "  フロントエンド..."
    docker compose exec -T frontend npm run lint

    log_info "  バックエンド確認..."
    if docker compose exec -T backend npm pkg get scripts.lint 2>/dev/null | grep -qv "{}"; then
        log_info "  バックエンドLint実行..."
        docker compose exec -T backend npm run lint
    else
        log_warning "  バックエンドLintスクリプトが未設定（スキップ）"
    fi

    log_success "Lint完了"
}

# 型チェックのみ
run_type_check() {
    log_info "型チェックを実行中..."

    log_info "  フロントエンド..."
    docker compose exec -T frontend npm run type-check

    log_info "  バックエンド..."
    docker compose exec -T backend npx tsc --noEmit

    log_success "型チェック完了"
}

# メイン処理
main() {
    cd "$PROJECT_ROOT"

    log_info "=========================================="
    log_info "テスト実行: target=$TARGET"
    log_info "=========================================="

    # コンテナ確認
    check_containers

    case "$TARGET" in
        all)
            run_frontend_tests
            echo ""
            run_backend_tests
            ;;
        frontend)
            run_frontend_tests
            ;;
        backend)
            run_backend_tests
            ;;
        lint)
            run_lint
            ;;
        type-check)
            run_type_check
            ;;
        *)
            log_error "不明なターゲット: $TARGET"
            echo "使用可能なターゲット: all, frontend, backend, lint, type-check"
            exit 1
            ;;
    esac

    echo ""
    log_success "=========================================="
    log_success "全テスト完了"
    log_success "=========================================="
}

main "$@"
