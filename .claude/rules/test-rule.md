## テスト実行環境
- **実行環境**: Dockerコンテナ上で実行（ローカル環境との差異を排除）
- **テストコマンド**: `./.claude/scripts/test.sh [target]`

## テスト種別と実行方法
```bash
# 全テスト実行
./.claude/scripts/test.sh all

# フロントエンドのみ
./.claude/scripts/test.sh frontend

# バックエンドのみ
./.claude/scripts/test.sh backend

# Lintのみ
./.claude/scripts/test.sh lint

# 型チェックのみ
./.claude/scripts/test.sh type-check
```

## Lint・フォーマッター実行ルール
- **Dockerコンテナ内で実行**: Prettier、ESLint等のフォーマッター・リンターは必ずDockerコンテナ内で実行する。ホスト環境で直接実行すると設定差異により不正なフォーマットが適用される可能性がある
- **実行方法**: `./.claude/scripts/test.sh lint` または `docker compose exec frontend npm run lint` を使用する

## テストカバレッジ目標
- ユニットテスト: 主要なビジネスロジック
- 統合テスト: API エンドポイント
- E2Eテスト: 重要なユーザーフロー（将来実装）
