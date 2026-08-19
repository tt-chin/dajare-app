# PRODUCT.md

## 1. Product Summary

### Working concept

子どもが自分でダジャレを考え、AIに判定してもらい、キャラクターのリアクションやスコアを楽しみながら、日本語の語彙・音・発想力に親しむアプリ。

### Product message

**親子で笑って、ことばを学ぶ。**

The app should feel like a game first and a language-learning experience second.

## 2. Target Users

### Primary users

- Japanese-speaking children aged 6–12
- Initial UX focus: elementary school grades 1–4

### Secondary users

- Parents who want a safe language-play activity to enjoy with children

## 3. Core User Experience

Primary flow:

```text
ホーム
  ↓
ダジャレを入力する
  ↓
AIがダジャレを判定
  ↓
スコア・説明・キャラクターリアクション
  ↓
ダジャレ図鑑に保存
```

Secondary flow:

```text
ホーム
  ↓
今日のお題
  ↓
お題に合うダジャレを考える
  ↓
必要ならヒントを見る
  ↓
AI判定
  ↓
結果
```

## 4. MVP Scope

### P0 — Required

- Home screen
- Text input for ダジャレ
- Firebase Functions call
- Gemini-based ダジャレ判定
- 0–100 score
- Result level
- Short child-friendly explanation
- Character reaction based on score
- Error handling
- Basic inappropriate-content handling

### P1 — Include in V1 if core flow is stable

- 今日のお題
- Hint
- ダジャレ図鑑
- Save successful / attempted ダジャレ
- Simple categories

Example categories:

- どうぶつ
- たべもの
- がっこう
- のりもの
- きせつ
- おばけ

### P2 — Later

- Japanese speech input
- Simple collection / unlock mechanics
- Multiple character reactions

### Not in MVP

- Public ranking
- Friends
- Public posting
- Child-to-child messaging
- Chat rooms
- Photo uploads
- Social feed

## 5. Main Screens

### 5.1 Home

Purpose:
- Make the next action obvious.

Primary actions:
- ダジャレを言う / 入力する
- 今日のお題
- ダジャレ図鑑

Design:
- Large buttons
- Minimal text
- Friendly character
- Avoid information-heavy layout

### 5.2 ダジャレ Input

Initial MVP:
- Text input
- Submit button
- Loading state

Later:
- Microphone button for Japanese speech recognition

Example input:

```text
パンダがパンだ！
```

### 5.3 Result

Show:

- Score: 0–100
- Reaction label
- Character reaction
- Detected wordplay pair
- Short explanation
- Save state

Example:

```text
92点！

うまい！🤣

「パンダ」と「パンだ」の音がそっくり！
```

### 5.4 今日のお題

Example:

```text
今日のお題：ねこ

「ねこ」を使ってダジャレを作ってみよう！
```

Hint example:

```text
「ねこ」と似た音のことばを考えてみよう。
```

Hints should assist without immediately giving a complete answer whenever possible.

### 5.5 ダジャレ図鑑

Purpose:
- Give children a reason to return.
- Let them see previous creations.

Each item may contain:

- Original phrase
- Score
- Category
- Date
- Simple badge / icon

## 6. Score Reactions

Initial proposed mapping:

| Score | Reaction |
|---|---|
| 0–39 | さむ～い！🥶 |
| 40–69 | いいね！😆 |
| 70–89 | うまい！🤣 |
| 90–99 | 天才！🤩 |
| 100 | 伝説のダジャレ王！👑 |

Important:
- Low scores must not feel like punishment.
- Avoid negative or discouraging language.
- The experience should remain playful even when the phrase is not a strong ダジャレ.

## 7. Design Principles

- Game-like rather than test-like
- Encourage creativity
- Short text
- Large touch targets
- Friendly reactions
- No harsh failure state
- Japanese appropriate for children
- Avoid difficult kanji where possible
- Furigana support can be considered later if necessary

## 8. Engagement

Potential later features:

- Daily challenge
- Collection cards
- Character unlocks
- Seasonal topics
- Parent-child ダジャレ battle

Do not build complicated reward systems before validating the core experience.

## 9. Parent-Child Mode — Future

Possible flow:

```text
Parent turn
→ score

Child turn
→ score

Winner announcement
```

This should remain local / family-oriented rather than becoming an online competitive feature.

## 10. MVP Success Criteria

The first release is successful if a child can:

1. Open the app.
2. Understand where to enter a ダジャレ.
3. Submit it without adult help.
4. Receive a fun result.
5. Understand why the phrase was recognized as a ダジャレ.
6. Want to try another one.

Technical success requires:

- Stable Firebase Functions communication
- Valid structured Gemini response
- Safe fallback behavior
- No secret keys in the client
- Android and iOS-compatible Flutter implementation
