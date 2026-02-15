< 以下参考 >

## コーディング規約

### TypeScript
- **インポートパス**: `@/*` エイリアスは `frontend/app/` をルートとして解決される。既存ファイルのインポートパスを参考にし、パスを推測しないこと
  - `@/common/` - 共通リソース（hooks, utils, constants, types 等）
  - `@/app/` - App Router ページ固有のコンポーネント・コンテキスト
  - `@/lib/` - ライブラリ関数
- **変数名の省略禁止**: `event`は`e`に、`error`は`err`等に省略しない。正式名称で記載する
- **厳格な型付け**: `any`の使用を避け、適切な型定義を行う
- **型定義ファイル**: 型の定義ファイルには、拡張子の .d を付ける
- **Null安全**: Optional Chaining (`?.`) と Nullish Coalescing (`??`) を活用
- **関数型プログラミング**: `map`, `filter`, `reduce`などを積極的に活用
- **非同期処理**: `async/await`を使用（Promiseチェーンは避ける）

### React/Next.js
- **関数コンポーネント**: クラスコンポーネントは使用しない
- **Hooks**: カスタムフックで共通ロジックを抽出
- **Props**: インターフェース (type) で型定義
- **Server Components**: デフォルトでServer Componentsを使用、必要時のみClient Componentsに
- **`'use client'`**: クライアント専用機能（useState, useEffect等）使用時のみ宣言

### NestJS
- **依存性注入**: コンストラクタインジェクションを使用
- **DTO**: クラスバリデーターでバリデーション
- **例外処理**: 適切なHTTP例外を使用
- **モジュール分割**: 機能ごとにモジュール化

### スタイリング
- **Tailwind CSS**: ユーティリティクラス優先
- **shadcn/ui**: カスタマイズ可能なコンポーネント活用

---
