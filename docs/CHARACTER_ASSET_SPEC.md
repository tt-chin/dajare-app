# CHARACTER_ASSET_SPEC.md — Character Asset Freeze v1

## Purpose
Defines the approved character assets for the child-facing Japanese ダジャレ app. Codex must not redesign, regenerate, recolor, rename, or replace approved assets without explicit approval.

## Stable Internal IDs
`character_a` and `character_b` are permanent technical IDs. They do not change when public/display names are decided or renamed.

```dart
enum CharacterId { characterA, characterB }
```

Do not derive asset paths from display names.

## Approved Reactions
Both characters have: `normal`, `cold`, `good`, `laugh`, `genius`, `legend`.

```dart
enum CharacterReaction { normal, cold, good, laugh, genius, legend }
```

| State | Usage | Reaction |
|---|---|---|
| normal | Home / neutral | normal |
| cold | 0–39 | さむ～い！🥶 |
| good | 40–69 | いいね！😆 |
| laugh | 70–89 | うまい！🤣 |
| genius | 90–99 | 天才！🤩 |
| legend | 100 | 伝説のダジャレ王！👑 |

Backend determines score/level; Flutter selects the approved visual asset.

## Frozen Paths
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

## Character Consistency
Preserve approved face/eyes, hairstyle and color arrangement, horn count/placement/design, clothing/colors, body proportions/age impression, and established 3D pastel toy/doll-like style. Reaction states may change pose/expression but must not redesign the character.

## Technical Requirements
Production assets should be transparent-background PNG, single-character, not accidentally cropped, without embedded text/logo/speech bubble/UI/scene, with sufficient transparent margin and reasonably consistent canvas/visual scale. Crowns, stars, confetti and similar effects should normally be separate Flutter overlays.

## Flutter Ownership
Flutter controls character, reaction, placement/size, transitions/animation and overlays. Gemini/Functions never return asset paths or visual implementation instructions. Centralize `(CharacterId, CharacterReaction) → asset path` mapping instead of scattering path strings across screens.

## MVP Usage
Home may use `normal`. Result uses score-mapped reaction assets. Early emoji placeholders are replaced when the relevant character UI task is implemented. Character-selection behavior may be defined separately and must not require folder renaming.

## Change Control
Explicit approval is required to add/remove reaction states, replace images, change appearance/internal IDs/score mapping, or add variants. Display-name changes do not require folder renaming.

## Status
**Character Asset Freeze v1: APPROVED**

Approved set: Character A and Character B × `normal/cold/good/laugh/genius/legend`.
