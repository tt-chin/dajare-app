# FLUTTER_UI_SPEC.md — Specification Freeze v1
## Frozen screens
`HomeScreen`, `DajareInputScreen`, `ResultScreen`, `DailyTopicScreen`, `CollectionScreen`.
Do NOT create Generate/Judge/Favorites/Settings primary screens in v1.

## Suggested structure
`lib/screens/`, `lib/models/`, `lib/services/`, `lib/widgets/`.
Reusable candidates: `PrimaryActionButton`, `ScoreCard`, `CharacterReaction`. Do not componentize one-off UI excessively.

## State/navigation
Simple `idle/submitting/success/error`. Standard Flutter navigation; Home is hub. No Riverpod/BLoC/Redux/DI just for MVP.

## Theme/layout
Use `ThemeData`; avoid per-screen design-system hardcoding. SafeArea, responsive width, 16–24dp padding, ≥56dp primary buttons, keyboard-safe CTA.

## Ownership
Flutter controls reaction visuals, assets, animation, colors, widgets, navigation. Gemini never does.

## Loading/error
Disable repeat submit, preserve input, translate internal errors to child-friendly copy.

## Assets
Start with one character + a few expressions/placeholders. No heavy animation package required.

## Checks
`dart format .`, `flutter analyze`, `flutter test`.
