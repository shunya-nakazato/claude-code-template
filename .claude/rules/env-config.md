< 以下の内容を参考とし、プロジェクトの実態に基づいて更新すること >

## 環境変数・設定管理方針

### `.env` ファイルの階層

| ファイル | 用途 | Git管理 |
|---|---|---|
| `.env` | 全環境共通のデフォルト値 | する |
| `.env.local` | 開発者個人のローカル設定 | しない |
| `.env.development` | 開発環境固有の設定 | する |
| `.env.staging` | ステージング環境固有の設定 | する |
| `.env.production` | 本番環境固有の設定 | する |

- 機密情報（APIキー、パスワード等）は `.env.local` またはシークレットマネージャーで管理し、Gitにコミットしない
- 環境固有ファイル（`.env.development` 等）には機密でない設定値のみを記載する

### 命名規則

- **共通**: `UPPER_SNAKE_CASE` を使用する
- **フロントエンド（Next.js）**: ブラウザに公開する変数は `NEXT_PUBLIC_` プレフィックスを付ける
- **バックエンド（NestJS）**: プレフィックスなし、または機能ごとのプレフィックスを付ける

| プレフィックス | 用途 | 例 |
|---|---|---|
| `NEXT_PUBLIC_` | フロントエンドで参照する値 | `NEXT_PUBLIC_API_URL` |
| `DB_` | データベース関連 | `DB_HOST`, `DB_PORT` |
| `AUTH_` | 認証関連 | `AUTH_SECRET`, `AUTH_EXPIRES_IN` |
| `MQTT_` | MQTT関連 | `MQTT_BROKER_URL`, `MQTT_PORT` |
| `FIREBASE_` | Firebase関連 | `FIREBASE_PROJECT_ID` |

### `.env.example` の運用ルール

- すべての環境変数を `.env.example` に記載する（値はダミーまたは空）
- 新しい環境変数を追加した場合、必ず `.env.example` も同時に更新する
- 各変数にはコメントで用途を説明する

```bash
# ----- データベース -----
DB_HOST=localhost
DB_PORT=5432

# ----- 認証 -----
AUTH_SECRET=          # JWTの署名キー（本番では強力なランダム文字列を設定）
AUTH_EXPIRES_IN=3600  # トークン有効期限（秒）

# ----- 外部サービス -----
FIREBASE_PROJECT_ID=my-project
```

### 必須 vs オプション環境変数

- 必須変数はアプリケーション起動時にバリデーションを行い、未設定の場合は起動を失敗させる
- NestJSでは `@nestjs/config` + `Joi` または `class-validator` でスキーマバリデーションを実施する
- オプション変数にはコード内でデフォルト値を定義する

```typescript
// 例: NestJSでの環境変数バリデーション
validationSchema: Joi.object({
  DB_HOST: Joi.string().required(),
  DB_PORT: Joi.number().default(5432),
  AUTH_SECRET: Joi.string().required(),
})
```

### フロントエンドでの注意事項

- `NEXT_PUBLIC_` 付き変数はビルド時に埋め込まれ、クライアントに公開される
- 機密情報には絶対に `NEXT_PUBLIC_` を付けない
- サーバーサイドのみで使用する変数は `NEXT_PUBLIC_` なしで定義する

---
