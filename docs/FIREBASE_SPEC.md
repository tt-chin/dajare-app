# FIREBASE_SPEC.md — 規格凍結 v1
## 技術組合
Anonymous Firebase Auth、Firestore、Functions 2nd gen、App Check。沒有需要時不加入其他 Firebase 產品。

## judgeDajare
HTTPS Callable。驗證 auth/App Check/請求/輸入/安全性，使用後端密鑰呼叫 Gemini，解析 structured output，驗證分數/schema，計算 `level`，套用輸出安全檢查，寫入可信結果，回傳正規化的回應。

## Auth
MVP 使用 Anonymous Auth。正式環境拒絕未經驗證的呼叫，且不得信任用戶端提供的 UID。

## Firestore
`users/{uid}`；`users/{uid}/dajareEntries/{entryId}`。
可信的判定結果欄位由伺服器控制。用戶端不得建立/更新假分數。使用者只能讀取自己的資料。預設拒絕存取。

Post-Task 14：每位使用者的図鑑保留最新 100 筆。Functions 在新結果成功保存後，以 `createdAt`（同時間以文件 ID）決定順序，由 Admin SDK 分批刪除較舊資料。只處理已驗證 UID 的 `dajareEntries`；cleanup 失敗記錄安全診斷並仍回傳判定結果，下次成功保存時再次整理。Flutter 維持新到舊的顯示順序，最多讀取 100 筆，不具刪除權限。

## 密鑰
使用 Firebase/Google Cloud Secret Manager，例如 `GEMINI_API_KEY`；不得 commit，也不得放在 Flutter/log/issue/範例中。

## App Check
發佈前：Android 使用 Play Integrity；iOS 使用支援的 App Attest/Apple 設定。Debug provider 只能在開發環境使用。啟用強制驗證（enforcement）前，應先觀察流量。

Task 13 準備 Flutter 端的 provider（debug build 使用 `debug`、Android 正式環境使用 Play Integrity、Apple 正式環境使用 App Attest 並以 DeviceCheck 作為備援）。在 Task 14 裝置驗證完成前，Console 的 enforcement 維持關閉。本機的 debug token 應在 Firebase Console 註冊；不得 commit。

## 頻率限制保護
`judgeDajare` 在 `users/{uid}/rateLimits/judgeDajare` 使用 Admin SDK Firestore transaction：每個 UID 冷卻 5 秒，每個 UTC 日最多接受 100 次。這份只供伺服器使用的文件，預設的 rules 會拒絕用戶端存取。驗證與安全檢查在扣除額度之前執行；扣除額度在呼叫 Gemini 之前執行。

## 錯誤
`unauthenticated`、`invalid_input`、`unsafe_input`、`rate_limited`、`ai_unavailable`、`invalid_ai_response`、`internal_error`。

## 隱私/log/成本
盡量減少儲存的資料；正式環境的 log 預設避免完整傾印原始 prompt/回應與使用者的完整文字。視需要加入合理的單一 UID/冷卻/每日限制、輸入長度限制、App Check 與監控。可行時使用 Auth/Functions/Firestore emulator。
