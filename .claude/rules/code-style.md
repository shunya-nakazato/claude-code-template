< 以下の内容を参考とし、プロジェクトの実態に基づいて更新すること >

# Google Style Guide — 命名規則一覧

Google公式スタイルガイドに基づく、各プログラミング言語およびMarkdownの命名規則をまとめたものです。

---

## 命名スタイル凡例

| スタイル名 | 例 |
|---|---|
| PascalCase (UpperCamelCase) | `MyClassName` |
| lowerCamelCase | `myVariable` |
| snake_case | `my_variable` |
| UPPER_SNAKE_CASE | `MAX_VALUE` |
| kebab-case | `my-file-name` |
| k + PascalCase (C++定数) | `kMaxSize` |

---

## C++

> 出典: [google.github.io/styleguide/cppguide.html](https://google.github.io/styleguide/cppguide.html)

| 項目 | 規則 | 例 |
|---|---|---|
| ファイル名 | snake_case（拡張子 `.cc` / `.h`） | `my_useful_class.cc` |
| 変数名 | snake_case（メンバ変数は末尾に `_`） | `my_exciting_local_variable`, `my_member_var_` |
| 関数名 | PascalCase（アクセサは snake_case） | `MyExcitingFunction()`, `get_count()` |
| クラス名 | PascalCase | `UrlTable`, `UrlTableTester` |
| 定数 | k + PascalCase | `kDaysInAWeek` |

---

## Java

> 出典: [google.github.io/styleguide/javaguide.html](https://google.github.io/styleguide/javaguide.html)

| 項目 | 規則 | 例 |
|---|---|---|
| ファイル名 | PascalCase（クラス名と一致、拡張子 `.java`） | `MyClass.java` |
| 変数名 | lowerCamelCase | `computedValues`, `index` |
| 関数名 | lowerCamelCase | `sendMessage()`, `stop()` |
| クラス名 | UpperCamelCase | `Character`, `ImmutableList` |
| 定数 | UPPER_SNAKE_CASE | `MAX_VALUE` |

---

## Python

> 出典: [google.github.io/styleguide/pyguide.html](https://google.github.io/styleguide/pyguide.html)

| 項目 | 規則 | 例 |
|---|---|---|
| ファイル名 | snake_case（拡張子 `.py`） | `my_module.py` |
| 変数名 | snake_case（グローバル定数は UPPER_SNAKE_CASE） | `local_variable`, `_GLOBAL_CONST` |
| 関数名 | snake_case | `my_function()` |
| クラス名 | UpperCamelCase | `MyClass`, `FooBar` |
| 定数 | UPPER_SNAKE_CASE | `MAX_HOLY_HANDGRENADE_COUNT` |

---

## JavaScript

> 出典: [google.github.io/styleguide/jsguide.html](https://google.github.io/styleguide/jsguide.html)

| 項目 | 規則 | 例 |
|---|---|---|
| ファイル名 | snake_case または kebab-case（拡張子 `.js`） | `my_module.js`, `my-module.js` |
| 変数名 | lowerCamelCase | `localCount` |
| 関数名 | lowerCamelCase | `sendMessage()` |
| クラス名 | UpperCamelCase | `Request`, `VisibilityMode` |
| 定数 | UPPER_SNAKE_CASE | `NUMBER_OF_DAYS` |

---

## TypeScript

> 出典: [google.github.io/styleguide/tsguide.html](https://google.github.io/styleguide/tsguide.html)

| 項目 | 規則 | 例 |
|---|---|---|
| ファイル名 | snake_case（拡張子 `.ts`） | `my_module.ts` |
| 変数名 | lowerCamelCase | `myVariable` |
| 関数名 | lowerCamelCase | `processData()` |
| クラス名 | UpperCamelCase | `TodoItem`, `HttpClient` |
| 定数 | UPPER_SNAKE_CASE | `UNIT_SUFFIXES` |

---

## Go

> 出典: [google.github.io/styleguide/go/](https://google.github.io/styleguide/go/)

| 項目 | 規則 | 例 |
|---|---|---|
| ファイル名 | snake_case（拡張子 `.go`、アンダースコア可） | `my_module.go` |
| 変数名 | lowerCamelCase（非公開） / UpperCamelCase（公開） | `maxLength` / `MaxLength` |
| 関数名 | lowerCamelCase（非公開） / UpperCamelCase（公開） | `parse()` / `NewClient()` |
| クラス名 | UpperCamelCase（struct / interface） | `Request`, `Reader` |
| 定数 | lowerCamelCase / UpperCamelCase（※UPPER_SNAKE_CASEは使わない） | `maxLength` / `MaxLength` |

---

## Kotlin

> 出典: [developer.android.com/kotlin/style-guide](https://developer.android.com/kotlin/style-guide)

| 項目 | 規則 | 例 |
|---|---|---|
| ファイル名 | PascalCase（クラス名と一致、拡張子 `.kt`） | `ProcessDeclarations.kt` |
| 変数名 | lowerCamelCase | `declarationCount` |
| 関数名 | lowerCamelCase | `processDeclarations()` |
| クラス名 | UpperCamelCase | `DeclarationProcessor` |
| 定数 | UPPER_SNAKE_CASE | `MAX_COUNT` |

---

## Swift

> 出典: [google.github.io/swift/](https://google.github.io/swift/)

| 項目 | 規則 | 例 |
|---|---|---|
| ファイル名 | PascalCase（型名と一致、拡張子 `.swift`） | `MyType.swift` |
| 変数名 | lowerCamelCase | `totalCount`, `isEnabled` |
| 関数名 | lowerCamelCase | `makeIterator()` |
| クラス名 | UpperCamelCase | `URLSession`, `MyController` |
| 定数 | lowerCamelCase | `maximumNumberOfLines` |

---

## Shell (Bash)

> 出典: [google.github.io/styleguide/shellguide.html](https://google.github.io/styleguide/shellguide.html)

| 項目 | 規則 | 例 |
|---|---|---|
| ファイル名 | snake_case（ライブラリは `.sh`、実行用は拡張子なし推奨） | `my_script.sh`, `deploy_server` |
| 変数名 | snake_case（ローカル） / UPPER_SNAKE_CASE（環境変数・定数） | `my_var` / `MY_CONST` |
| 関数名 | snake_case | `my_function()` |
| クラス名 | —（クラス概念なし） | — |
| 定数 | UPPER_SNAKE_CASE | `VERBOSE`, `MAX_RETRIES` |

---

## Markdown

> 出典: [google.github.io/styleguide/docguide/style.html](https://google.github.io/styleguide/docguide/style.html)

| 項目 | 規則 | 例 |
|---|---|---|
| ファイル名 | kebab-case（小文字、拡張子 `.md`） | `getting-started.md`, `api-reference.md` |
| 特殊ファイル | UPPER_SNAKE_CASE（GitHubが自動認識する定番ファイル） | `README.md`, `CONTRIBUTING.md`, `CHANGELOG.md` |

### 補足

- Googleのドキュメントスタイルガイドでは **小文字の kebab-case** を推奨しています。
- `README.md`, `CONTRIBUTING.md`, `LICENSE.md`, `CODE_OF_CONDUCT.md` などのプロジェクトルートに置く定番ファイルは慣習的に大文字で書きます。これはGitHubが自動認識してUIに表示すること、またASCIIソート順でディレクトリ一覧の上部に表示されるという実用的な理由があります。
- 静的サイトジェネレーター（Jekyll, Hugo, Gatsby等）ではファイル名がそのままURLパスになるため、kebab-case はSEOの観点からも最適です。

---

## 横断比較：命名スタイル早見表

| 言語 | ファイル名 | 変数名 | 関数名 | クラス名 | 定数 |
|---|---|---|---|---|---|
| **C++** | snake_case | snake_case | PascalCase | PascalCase | kPascalCase |
| **Java** | PascalCase | lowerCamelCase | lowerCamelCase | UpperCamelCase | UPPER_SNAKE |
| **Python** | snake_case | snake_case | snake_case | UpperCamelCase | UPPER_SNAKE |
| **JavaScript** | snake/kebab | lowerCamelCase | lowerCamelCase | UpperCamelCase | UPPER_SNAKE |
| **TypeScript** | snake_case | lowerCamelCase | lowerCamelCase | UpperCamelCase | UPPER_SNAKE |
| **Go** | snake_case | camelCase | camelCase | PascalCase | camelCase |
| **Kotlin** | PascalCase | lowerCamelCase | lowerCamelCase | UpperCamelCase | UPPER_SNAKE |
| **Swift** | PascalCase | lowerCamelCase | lowerCamelCase | UpperCamelCase | lowerCamelCase |
| **Shell** | snake_case | snake_case | snake_case | — | UPPER_SNAKE |
| **Markdown** | kebab-case | — | — | — | — |

---

*本資料は Google Style Guides（google.github.io/styleguide/）の2025年時点の公開情報に基づいています。*


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
