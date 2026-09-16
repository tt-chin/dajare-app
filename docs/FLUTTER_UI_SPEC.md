# FLUTTER_UI_SPEC.md — 規格凍結 v1
## 凍結的畫面
`HomeScreen`、`DajareInputScreen`、`ResultScreen`、`DailyTopicScreen`、`CollectionScreen`。
v1 不得建立 Generate/Judge/Favorites/Settings 這類主要畫面。

## 建議結構
`lib/screens/`、`lib/models/`、`lib/services/`、`lib/widgets/`。
可重用的候選元件：`PrimaryActionButton`、`ScoreCard`、`CharacterReaction`。不得過度把只用一次的 UI 元件化。

## 狀態/導覽
使用簡單的 `idle/submitting/success/error`。使用標準 Flutter 導覽；Home 是中心。MVP 不得只為了這個目的導入 Riverpod/BLoC/Redux/DI。

## 主題/版面
使用 `ThemeData`；避免在各畫面寫死設計系統的數值。SafeArea、響應式寬度、16–24dp 邊距、≥56dp 主要按鈕、CTA 不被鍵盤遮住。

## 權責
Flutter 負責反應的視覺呈現、素材、動畫、顏色、widget、導覽。Gemini 不得負責這些。

## 載入/錯誤
停用重複送出、保留輸入內容、把內部錯誤轉換成適合兒童的文案。

## 素材
先從一個角色 + 少數表情/佔位圖開始。不需要重量級的動畫套件。

## 檢查
`dart format .`、`flutter analyze`、`flutter test`。

## Post-Task 14：Result Animation & Sound
- 判定等待中使用已選角色的正式 PNG sequence：`assets/animations/character_a/judging/` 或 `character_b/judging/` 的 frame_00～23，24 frames / 8 FPS / 3 秒，00→23→00 循環。依真正的請求完成時間結束，不延遲 AI 回應；載入失敗退回原有 normal PNG。
- Result 使用既有 level → reaction 對應，約 700ms 的輕微 scale/bounce 後顯示完整結果。系統要求減少動畫時直接顯示。
- 一般設定畫面提供サウンド ON/OFF，沿用 shared_preferences 本地保存（`sound_enabled`，預設 OFF）；啟動時角色選擇流程不變。
- 沿用 audioplayers 與單一音效服務。一般畫面（含角色選擇、Home、輸入、題目、圖鑑、設定）循環 background.mp3；判定等待時停止一般 BGM，改循環 judging.mp3；結果畫面停止判定 BGM，返回一般畫面後恢復一般 BGM。切換歌曲由頭開始，不保留原播放位置。
- Sound OFF 或背景狀態會停止播放；回到前景時依目前畫面恢復需要的 BGM。結果 SE 不因返回前景重播。現有 reaction SE 擴充點保留，但此次素材未提供 SE。
- 音源可省略，缺少或播放失敗不影響判定。檔名與加入方式見 `assets/audio/README.md`；不得使用授權不明音源。
