# DEVELOPMENT_PLAN.md — 規格凍結 v1
Codex 一次只實作一個任務，完成後停下來等待審查。

01 Flutter 初始化 — 最小的 iOS/Android app；不含 Firebase/Gemini/最終 UI。
02 結構 + Home — 凍結的三個 Home 操作。
03 文字輸入 — 驗證/可顯示載入中/模擬結果。
04 Firebase Flutter — 初始化/設定 Firebase；用戶端不放 Gemini 密鑰。
05 Functions 基礎 — Flutter → callable → `Hello Dajare!`。
06 Gemini — Functions 經由後端密鑰呼叫 Gemini/structured output 測試。
07 AI 判定 — 依 AI/PROMPT 規格實作 schema/範圍/level/安全備援。
08 Result UI — 分數/反應/角色/評語/詞語組合/Try Again。
09 今日のお題 — 靜態題目 + 一步提示，重用核心流程。
10 Anonymous Auth + Firestore — 嚴格的 rules；正式環境的 callable 驗證。
11 図鑑 — 保存/讀取自己的、經驗證且由伺服器控制的結果。
12 日文語音 — 權限/辨識結果進入同一條文字處理流程。
13 安全強化 — 安全、App Check、rules、log、頻率/成本/錯誤。
14 Android/iOS 驗證 — Android emulator/裝置；iOS macOS/雲端/TestFlight 流程。
15 發佈 — 素材/隱私/設定/build/當下 Apple/Google 政策審查。

里程碑：A=01–03；B=04–08；C=09–11；D=12–14；E=15。

## Task 14 進度
- iOS simulator（iPhone 17 Pro、iOS 26.5、Xcode 26.6）：可 build、啟動並進入首頁（Firebase 初始化 + App Check + Anonymous Auth 皆通過）。
- Build 修正：iOS deployment target 13.0 → 15.0（Firebase plugins 需要 15.0）；`cloud_functions` 6.3.6 → 6.4.0（6.3.6 搭配 `firebase_core` 4.14.0 會因重複宣告 `FlutterError: Error` 導致 Swift 編譯失敗）；將 `GoogleService-Info.plist` 加入 Runner target resources（原本沒有打包進 app）。
- 本機環境：CocoaPods CDN 索引過舊時，需要先執行 `pod repo update`。
- FlutterFire plugins 應一起升級；原生版本不一致會讓 iOS build 失敗。
- 實機 iPhone（iPhone 13 mini、iOS 26.6.1、USB）：使用 `DEVELOPMENT_TEAM` N75N3Q3M5J 簽章，可 build、安裝、啟動。
- App Check：裝置 log 原本出現 403 `Firebase App Check API has not been used in project 416889139850 before or it is disabled`。目前 API 已啟用；iPhone 13 mini debug build 的 debug token 已在 Firebase Console 註冊（token 不得 commit）。註冊後重新啟動 app，log 中沒有 403/attestation 錯誤，判定流程正常。
  - debug token 會印在 `flutter run` 的輸出中；同一次安裝會沿用同一個 token，刪除重裝後會產生新的 token，需要重新註冊。
  - 已確認（tt-chin 查看 `judgeDajare` log）：App Check VALID、Anonymous Auth VALID、Callable request verification passed。
  - `judgeDajare` 仍是 `enforceAppCheck: false`（`functions/src/index.ts`）。改成 `true` 之前，要確認 release/TestFlight build 的 App Attest provider 已設定，其他開發者的 debug build 也要各自註冊 debug token。
- 實機 iPhone：`judgeDajare` 完整流程正常（有顯示分數/反應/評語/詞語組合）。
- 判定成功後図鑑為空：已解決。Functions SDK 已有具名 app 時，Admin SDK 的 default app 從未被建立，導致 `getFirestore()` 失敗，存檔錯誤又被 `onSaveFailure` 吞掉。已在 `067125f` 修正（`functions/src/firestore_client.ts` 的 `getDefaultFirestore`，`rate_limit.ts` 也改用它，並加入安全的診斷 log）；已部署並在 iPhone 上驗證（新的判定會出現在図鑑）。部署前判定的紀錄從未被儲存。
- 範圍決定：只驗證 iOS；Android 驗證目前不在範圍內。
- 語音輸入已修正並在裝置上驗證：原本收到第一筆部分結果時，UI 就離開 `listening`，也沒有設定 `listenFor`/`pauseFor`，導致辨識一直進行、文字跨次累積。現在會自動停止（10 秒/3 秒），手動停止正常，會在 `SpeechToText` singleton 上重新綁定 listener；沒偵測到講話（`error_no_match`/`error_speech_timeout`）時顯示重試訊息，而不是「麥克風無法使用」。
- `flutter run` 斷線後若 app 繼續執行，debug build 會當掉（SIGBUS、KERN_CODESIGN_ERROR）；請保持 debugger 連線，或使用 `--release` 進行不接線的測試。
- TestFlight：build 1.0.0 (1) 已從 Xcode Organizer 以「TestFlight Internal Only」上傳（bundle ID `com.ttchin.dajareApp`，Cloud Managed Apple Distribution 簽章）。上傳前先在裝置上驗證 release build。Info.plist 已加入 `ITSAppUsesNonExemptEncryption = false`。launch image 仍是 Flutter 預設的佔位圖。team 中有一個先前嘗試時留下、未使用的 App ID `com.rtsai.dajareApp`。

當被要求執行 `Task XX` 時：閱讀相關規格、檢查 repo、只實作 XX、執行檢查、回報變更的檔案/指令/結果/手動步驟，然後停止。
