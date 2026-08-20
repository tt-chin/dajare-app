# UI_UX_SPEC.md — Specification Freeze v1
## Principles
Game first; one obvious primary action; short easy Japanese; low cognitive load; positive low-score feedback; no unnecessary personal data; no raw AI/technical errors.

Touch: primary button ≥56dp; icon area ≥48dp. Use SafeArea, 16–24dp side padding, readable OS Japanese fonts, text scaling, and do not rely on color alone.

## IA
Home
├─ Input → Loading → Result → Try Again
├─ Daily Topic → Hint → Input/Result
└─ Collection
No Bottom Navigation required for MVP.

## Home
`ダジャレを入力する` primary; `今日のお題`, `ダジャレ図鑑` secondary. No forced login/tutorial/settings.

## Input
`ダジャレを入れてみよう！`; CTA `判定する！`.
Empty: `ダジャレを入れてみてね！`; too long: `もう少し短くしてみてね！`. Prevent double submit; preserve text on retry.

## Loading
Progress + `ダジャレチェック中！`.

## Result
Score → reaction → character → short explanation → word pair → `もういっかい！`. No harsh failure state/red X.

## Daily Topic
One topic/category, `ダジャレを作る`, one-step `ヒントをみる`; bundled/static initially.

## Collection
Phrase, score/reaction, optional category/date; useful empty state.

## Errors
Network: `ネットにつながらなかったみたい。もういちどためしてみてね！`
AI: `うまく判定できなかったみたい。もういちどためしてみてね！`
Unsafe: `ほかのことばでダジャレを作ってみよう！どうぶつや食べものがおすすめだよ。`
