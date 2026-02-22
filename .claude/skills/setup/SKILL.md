# Skill: プロジェクトセットアップ

## 概要
テンプレートの各ルールファイル・スキルをプロジェクトに合わせて対話型でカスタマイズする。

## トリガー
ユーザーが `/setup` を実行した時

## フロー

以下のステップを順番に実行する。
各ステップの冒頭で AskUserQuestion を使い「設定する / スキップ」を選択させる。
スキップされた項目はテンプレートのデフォルトのまま残す。

### Step 1: プロジェクト基本情報
- プロジェクト名、概要、目的をヒアリング
- 出力: `rules/project-info.md`

### Step 2: 技術スタック
- フロントエンド（Next.js / Nuxt / なし / Other）
- バックエンド（NestJS / Express / Go / なし / Other）
- データベース（Firestore / PostgreSQL / MySQL / なし / Other）
- 認証（Firebase Auth / Auth0 / 自前 / なし / Other）
- インフラ（Docker / なし / Other）
- 既存の package.json や設定ファイルがあれば自動検出しデフォルト値に反映する
- 出力: `rules/tech-stack.md`

### Step 3: コーディングルール
- 主要言語（TypeScript / Python / Go / Other）
- コメント言語（日本語 / 英語）
- 既存のlint設定（.eslintrc, prettier等）があれば読み取って反映
- 出力: `rules/code-style.md`, `rules/code-rule.md`

### Step 4: テスト戦略
- テストフレームワーク（Jest / Vitest / pytest / go test / Other）
- 実行環境（Docker / ローカル）
- テスト種別（unit / integration / e2e から複数選択）
- 出力: `rules/test-rule.md`, `skills/test/SKILL.md`

### Step 5: CI/CD
- CIツール（GitHub Actions / GitLab CI / なし / Other）
- デプロイ先（Vercel / AWS / GCP / なし / Other）
- 出力: `rules/cicd-rule.md`

### Step 6: セキュリティ
- Step 2の技術スタックに応じたセキュリティ要件を提示
- 追加のセキュリティ要件をヒアリング
- 出力: `rules/security-mgmt.md`

### 完了
- 設定済み / スキップの一覧をサマリー表示する
- スキップした項目は後から再度 `/setup` で設定可能であることを案内する

## ルール
- 各ステップで AskUserQuestion を使用し、選択肢を提示する
- 選択肢には必ず「スキップ」を含める
- ファイル生成後、内容をユーザーに提示し確認を得る
- 既存ファイルを上書きする場合は事前に確認する
