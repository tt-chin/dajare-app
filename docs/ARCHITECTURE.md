# ARCHITECTURE.md — 規格凍結 v1
## 架構
Flutter → Anonymous Auth → HTTPS Callable `judgeDajare` → Functions 2nd gen → Gemini → 驗證/level/可信的 Firestore 寫入 → 正規化後的 Flutter 結果。

### Flutter
UI/導覽/輸入/載入/錯誤/角色呈現/呼叫 callable/讀取自己被允許存取的資料。不得呼叫 Gemini、持有密鑰、顯示原始 AI 內容或寫入可信分數。

### Functions
以下事項的最終決定權：auth、App Check、驗證、安全、Gemini、schema/分數驗證、level 對應、可信資料保存、正規化錯誤。

### Gemini
只回傳 `isDajare`、`score`、`word1`、`word2`、`comment`。不控制 UI/導覽/動畫/level。

## Flutter 結構
`lib/main.dart`、`screens/`、`models/`、`services/`、`widgets/`；不建立不必要的 domain/repository 層。

## Firestore
`users/{uid}` 與 `users/{uid}/dajareEntries/{entryId}`。可信的結果欄位由伺服器產生。

## 錯誤
後端：`unauthenticated`、`invalid_input`、`unsafe_input`、`rate_limited`、`ai_unavailable`、`invalid_ai_response`、`internal_error`。
Flutter 本地：`network_error`。不得把錯誤代碼顯示給兒童看。

## Auth 導入時機
Task 04–07 可以漸進式製作原型。Task 10 正式導入 Anonymous Auth/資料保存。正式環境必須具備 Auth + App Check + 合理的濫用/成本防護。
