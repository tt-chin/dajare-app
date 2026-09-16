# CHARACTER_ASSET_SPEC.md — 角色素材凍結 v1

## 目的
定義兒童向日文ダジャレ app 已核准的角色素材。未經明確核准，Codex 不得重新設計、重新生成、改色、改名或替換已核准的素材。

## 固定的內部 ID
`character_a` 與 `character_b` 是永久的技術 ID。決定或變更公開/顯示名稱時，這些 ID 不會改變。

```dart
enum CharacterId { characterA, characterB }
```

不得從顯示名稱推導素材路徑。

## 已核准的反應
兩個角色都有：`normal`、`cold`、`good`、`laugh`、`genius`、`legend`。

```dart
enum CharacterReaction { normal, cold, good, laugh, genius, legend }
```

| 狀態 | 用途 | 反應 |
|---|---|---|
| normal | Home / 中性 | normal |
| cold | 0–39 | さむ～い！🥶 |
| good | 40–69 | いいね！😆 |
| laugh | 70–89 | うまい！🤣 |
| genius | 90–99 | 天才！🤩 |
| legend | 100 | 伝説のダジャレ王！👑 |

後端決定分數/level；Flutter 選擇已核准的視覺素材。

## 凍結的路徑
```text
assets/characters/
├── character_a/
│   ├── normal.png
│   ├── cold.png
│   ├── good.png
│   ├── laugh.png
│   ├── genius.png
│   └── legend.png
└── character_b/
    ├── normal.png
    ├── cold.png
    ├── good.png
    ├── laugh.png
    ├── genius.png
    └── legend.png
```

## 角色一致性
應保留已核准的臉部/眼睛、髮型與配色、角的數量/位置/設計、服裝/顏色、身體比例/年齡印象，以及既定的 3D 粉彩玩具/人偶風格。反應狀態可以改變姿勢/表情，但不得重新設計角色。

## 技術需求
正式素材應為透明背景 PNG、單一角色、沒有被意外裁切、不含內嵌的文字/logo/對話框/UI/場景，保留足夠的透明邊距，且畫布/視覺比例大致一致。皇冠、星星、彩帶等效果通常應以獨立的 Flutter 疊加層呈現。

## Flutter 權責
Flutter 控制角色、反應、位置/大小、轉場/動畫與疊加層。Gemini/Functions 不得回傳素材路徑或視覺實作指示。`(CharacterId, CharacterReaction) → asset path` 的對應應集中管理，不要把路徑字串分散在各個畫面中。

## MVP 使用方式
Home 可以使用 `normal`。Result 使用依分數對應的反應素材。早期的 emoji 佔位圖，會在實作相關的角色 UI 任務時替換。角色選擇行為可以另外定義，且不得需要重新命名資料夾。

## 變更管理
新增/移除反應狀態、替換圖片、變更外觀/內部 ID/分數對應，或新增變體，都需要明確核准。變更顯示名稱不需要重新命名資料夾。

## 狀態
**Character Asset Freeze v1: APPROVED**（角色素材凍結 v1：已核准）

已核准的組合：Character A 與 Character B × `normal/cold/good/laugh/genius/legend`。

## Post-Task 14：正式判定等待 sequence
使用使用者提供的 `character_a_judging_optimized.zip` 與 `character_b_judging_optimized.zip` 原始 PNG，不加工、不重新生成。路徑為 `assets/animations/{character_a|character_b}/judging/frame_00.png`～`frame_23.png`。每組 24 張 416×560 RGBA，8 FPS，3 秒正向循環。此素材只用於等待，原有 reaction PNG 與 level 對應維持不變。
