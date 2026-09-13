# AGENTS.md — 規格凍結 v1
給 6–12 歲兒童的日文ダジャレ app。Flutter iOS/Android + Firebase + 經由 Firebase Functions 呼叫 Gemini。

## 規則
- 架構應保持簡單，讓初學者也能維護；避免過早導入 Clean Architecture/BLoC/重量級 DI。
- 在可行範圍內共用 iOS/Android 程式碼。保留可正常運作的程式碼；優先採用小幅修改。
- 不得將 Gemini/API 密鑰存放在 Flutter 或版本控制中。Flutter 不得直接呼叫 Gemini。
- 兒童安全、隱私與資料最小化是必須遵守的要求。
- Codex 一次只實作一個 DEVELOPMENT_PLAN 任務，完成後停下來等待審查。
- 可信的 AI 分數/結果由伺服器控制，Flutter 不得寫入。
- 已核准的角色素材未經明確核准，不得重新設計、重新生成、改色、改名或替換。
- `character_a` 與 `character_b` 是永久的內部 ID；不得以顯示名稱作為素材資料夾 ID。
- 角色/反應與素材路徑的對應應集中管理，不要把字串分散在各個畫面中。

## 凍結的正式環境流程
Flutter → Anonymous Auth → callable `judgeDajare` → Auth/App Check/輸入/安全驗證 → Gemini → structured output → 後端驗證 + level → 可信的 Firestore 寫入 → Flutter。

## MVP 不包含的項目
不提供公開聊天、訊息、好友、公開貼文/排行榜、社群動態或照片上傳。

## 規格依據（Source of Truth）
1. `docs/PRODUCT.md`
2. `docs/UI_UX_SPEC.md`
3. `docs/FLUTTER_UI_SPEC.md`
4. `docs/ARCHITECTURE.md`
5. `docs/AI_SPEC.md`
6. `docs/PROMPT_SPEC.md`
7. `docs/FIREBASE_SPEC.md`
8. `docs/SAFETY_PRIVACY.md`
9. `docs/DEVELOPMENT_PLAN.md`
10. 角色素材 → `docs/CHARACTER_ASSET_SPEC.md`

`docs/CHARACTER_ASSET_SPEC.md` 是角色 ID、反應狀態、素材路徑、一致性與變更管理的權威依據。

若規格之間互相衝突，應停下來指出衝突，而不是自行發明解決方式。
