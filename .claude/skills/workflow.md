# Skill: ワークフロー自律実行

## トリガー
実装タスクが指示された時

## フロー
```
Phase 1: Plan Loop
  1. plan-<UTC>.md 作成
  2. codex exec → GO判定
  3. GO出るまで修正のみ
  ※ GOなしで実装禁止

Phase 2: Implementation Loop
  1. ブランチ作成
  2. plan-<UTC>.mdに従い実装
  3. docker compose でテスト
  4. codex review

Phase 3: Review Loop
  1. grep "CODEX:" で確認
  2. 全コメント修正
  3. テスト再実行
  4. PASS出るまで繰り返し

Phase 4: Completion
  1. git commit
  2. gh pr create
  3. feature/stageへマージ
```

## 自動実行OK
- ファイル読み取り・検索
- plan.md作成・修正
- コード実装・修正
- テスト実行
- ブランチ作成・コミット

## Codex承認必須
- Phase 1→2: GO
- Phase 3→4: PASS

## 禁止
- GOなしで実装
- CODEXコメント無視
- テスト未実行で完了
