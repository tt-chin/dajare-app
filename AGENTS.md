# AGENTS.md

## Project Overview

This repository contains a Japanese wordplay app (ダジャレアプリ) for children aged 6–12.

The app is designed for iOS and Android using Flutter.
The backend uses Firebase, and Gemini API calls must be made through Firebase Functions.

## Core Principles

1. Prioritize maintainability for beginner developers.
2. Avoid unnecessary architectural complexity.
3. Reuse implementation across iOS and Android whenever possible.
4. Never embed Gemini API keys or other secrets directly in the Flutter app.
5. Gemini API must normally be called through Firebase Functions.
6. Child safety, privacy, and inappropriate-content prevention are high priorities.
7. Respect the current architecture and avoid unnecessary rewrites.
8. Prefer small, reviewable changes.
9. Do not introduce new packages unless there is a clear need.
10. Keep UI and business logic reasonably separated without adopting excessive abstraction.

## Target Users

- Primary target: children aged 6–12
- Initial UX focus: elementary school children
- Language: Japanese
- Design goal: simple, friendly, playful, and easy to understand without adult assistance

## Planned Technology Stack

- Flutter
- Dart
- iOS / Android
- Firebase Authentication
- Cloud Firestore
- Firebase Functions
- Gemini API
- Main development environment: Windows PC

## AI Integration Rules

The Flutter application must not call Gemini directly.

Preferred flow:

Flutter
→ Firebase Functions
→ Gemini API
→ Firebase Functions
→ Flutter

Gemini output should be validated server-side before returning it to the app.

## Child Safety Rules

- Do not implement public chat in MVP.
- Do not implement user-to-user messaging in MVP.
- Do not implement public posting in MVP.
- Do not expose children's personal information.
- Do not ask children for unnecessary personal information.
- AI responses must avoid sexual, violent, discriminatory, frightening, or otherwise age-inappropriate content.
- Unexpected or unsafe AI output must fail safely with a child-friendly fallback message.

## Development Style

When implementing a task:

1. Read the relevant files under `docs/`.
2. Check the existing implementation before modifying files.
3. Make the smallest reasonable change.
4. Preserve existing behavior unless the task explicitly changes it.
5. Add or update tests where practical.
6. Run formatting and static analysis.
7. Report changed files and any known limitations.

## Recommended Validation Commands

Typical Flutter validation:

```bash
flutter pub get
dart format .
flutter analyze
flutter test
```

Typical Firebase Functions validation commands depend on the package scripts defined in `functions/package.json`.

Do not assume a command exists without checking the repository first.

## Source of Truth

Product requirements:
- `docs/PRODUCT.md`

Technical architecture:
- `docs/ARCHITECTURE.md`

Gemini / ダジャレ判定 specification:
- `docs/AI_SPEC.md`

If implementation and documentation conflict, stop and identify the conflict before making a large design change.
