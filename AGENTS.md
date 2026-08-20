# AGENTS.md — Specification Freeze v1
Japanese ダジャレ app for children aged 6–12. Flutter iOS/Android + Firebase + Gemini via Firebase Functions.

## Rules
- Keep architecture simple and beginner-maintainable; avoid premature Clean Architecture/BLoC/heavy DI.
- Share iOS/Android code where practical. Preserve working code; prefer small changes.
- Never store Gemini/API secrets in Flutter/source control. Flutter never calls Gemini directly.
- Child safety/privacy/data minimization are mandatory.
- Codex implements one DEVELOPMENT_PLAN task at a time and stops for review.
- Trusted AI scores/results are server-controlled and not writable by Flutter.

## Frozen production flow
Flutter → Anonymous Auth → callable `judgeDajare` → Auth/App Check/Input/Safety validation → Gemini → structured output → backend validation + level → trusted Firestore write → Flutter.

## MVP exclusions
No public chat, messaging, friends, public posts/rankings, social feed, or photo upload.

## Source of Truth
1. `docs/PRODUCT.md`
2. `docs/UI_UX_SPEC.md`
3. `docs/FLUTTER_UI_SPEC.md`
4. `docs/ARCHITECTURE.md`
5. `docs/AI_SPEC.md`
6. `docs/PROMPT_SPEC.md`
7. `docs/FIREBASE_SPEC.md`
8. `docs/SAFETY_PRIVACY.md`
9. `docs/DEVELOPMENT_PLAN.md`

If specs conflict, stop and identify the conflict instead of inventing a resolution.
