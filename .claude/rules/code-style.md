## フロントエンド (Next.js + TypeScript)

### ディレクトリ構造
以下の構成はあくまで参考程度
フォルダ名まで完全に一致させる必要はない。

```
./
├── app/                        # App Router ページ
│   ├── (auth)/                 # 認証関連ページグループ
│   │   ├── login/
│   │   └── register/
│   ├── (dashboard)/            # ダッシュボードページグループ
│   │   ├── editor/             # コンテンツエディタ
│   │   │   ├── _components/   # ページ固有コンポーネント
│   │   │   ├── _hooks/        # ページ固有カスタムフック
│   │   │   ├── _utils/        # ページ固有ユーティリティ
│   │   │   ├── _types/        # ページ固有型定義
│   │   │   ├── _contexts/     # ページ固有Context
│   │   │   ├── _dals/         # Data Access Layer
│   │   │   └── page.tsx
│   │   ├── devices/            # デバイス管理
│   │   └── library/            # コンテンツライブラリ
│   ├── api/                    # API Routes (必要に応じて)
│   ├── layout.tsx              # ルートレイアウト
│   ├── page.tsx                # トップページ
│   ├── loading.tsx             # グローバルローディング
│   ├── error.tsx               # グローバルエラー
│   └── not-found.tsx           # 404ページ
│
├── common/                     # 共通リソース
│   ├── components/             # 再利用可能コンポーネント
│   │   ├── ui/                 # shadcn/ui コンポーネント
│   │   ├── layouts/            # レイアウトコンポーネント
│   │   └── features/           # 機能別コンポーネント
│   ├── hooks/                  # 共通カスタムフック
│   ├── utils/                  # 共通ユーティリティ関数
│   ├── types/                  # 共通型定義
│   ├── contexts/               # 共通Context
│   ├── dals/                   # 共通Data Access Layer
│   ├── constants/              # 定数定義
│   └── styles/                 # グローバルスタイル
│
├── public/                     # 静的アセット
│   ├── images/
│   ├── fonts/
│   └── icons/
│
├── tests/                      # テストファイル
│   ├── unit/
│   └── integration/
│
├── .env.local                  # ローカル環境変数（Gitignore対象）
├── .env.example                # 環境変数のサンプル
├── next.config.js              # Next.js設定
├── tailwind.config.ts          # Tailwind CSS設定
├── tsconfig.json               # TypeScript設定
└── package.json
```

### 命名規則

#### ファイル・ディレクトリ
- **ページコンポーネント**: `page.tsx`
- **レイアウト**: `layout.tsx`
- **ローディング**: `loading.tsx`
- **エラーハンドリング**: `error.tsx`
- **404ページ**: `not-found.tsx`
- **コンポーネント**: PascalCase（例: `UserCard.tsx`）
- **Hooks**: camelCaseで`use`プレフィックス（例: `useAuth.ts`）
- **Utils**: camelCase（例: `formatDate.ts`）
- **Types**: PascalCase（例: `User.ts`, `ContentItem.ts`）
- **定数**: UPPER_SNAKE_CASE（例: `API_ENDPOINTS.ts`）

#### コード
- **変数・関数**: camelCase
- **クラス・インターフェース・型**: PascalCase
- **定数**: UPPER_SNAKE_CASE

### コメントスタイル

#### セクション区切り
- セクション区切りには `// ----- セクション名 -----` を使用する
- `// ===...` 形式の装飾的なブロックコメントは使用しない

#### 関数ヘッダー
- 全ての関数・メソッドに以下の形式のJSDocヘッダーを付ける
```
/** 
 * 説明 
 */
```
---

## バックエンド (NestJS)

### ディレクトリ構造

```
./
├── src/
│   ├── modules/                # 機能モジュール
│   │   ├── auth/               # 認証モジュール
│   │   │   ├── auth.controller.ts
│   │   │   ├── auth.service.ts
│   │   │   ├── auth.module.ts
│   │   │   ├── dto/            # Data Transfer Objects
│   │   │   ├── guards/         # 認証ガード
│   │   │   └── strategies/     # 認証戦略
│   │   ├── content/            # コンテンツ管理モジュール
│   │   ├── device/             # デバイス管理モジュール
│   │   └── mqtt/               # MQTT通信モジュール
│   ├── common/                 # 共通リソース
│   │   ├── decorators/
│   │   ├── filters/            # 例外フィルター
│   │   ├── guards/
│   │   ├── interceptors/
│   │   ├── pipes/              # バリデーションパイプ
│   │   └── utils/
│   ├── config/                 # 設定ファイル
│   ├── database/               # DB関連
│   ├── app.module.ts           # ルートモジュール
│   └── main.ts                 # エントリーポイント
│
├── test/                       # E2Eテスト
├── .env                        # 環境変数（Gitignore対象）
├── .env.example                # 環境変数のサンプル
├── nest-cli.json               # NestJS CLI設定
├── tsconfig.json               # TypeScript設定
└── package.json
```

### 命名規則

#### ファイル・ディレクトリ
- **Utils**: camelCase（例: `formatDate.ts`）
- **Types**: PascalCase（例: `User.ts`, `ContentItem.ts`）
- **定数**: UPPER_SNAKE_CASE（例: `API_ENDPOINTS.ts`）

#### コード
- **変数・関数**: camelCase
- **クラス・インターフェース・型**: PascalCase
- **定数**: UPPER_SNAKE_CASE
