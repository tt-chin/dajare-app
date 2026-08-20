# ARCHITECTURE.md — Specification Freeze v1
## Architecture
Flutter → Anonymous Auth → HTTPS Callable `judgeDajare` → Functions 2nd gen → Gemini → validation/level/trusted Firestore write → normalized Flutter result.

### Flutter
UI/navigation/input/loading/error/character presentation/callable calls/read own allowed data. No Gemini call, secrets, raw AI display, or trusted-score writes.

### Functions
Final authority for auth, App Check, validation, safety, Gemini, schema/score validation, level mapping, trusted persistence, normalized errors.

### Gemini
Returns only `isDajare`, `score`, `word1`, `word2`, `comment`. No UI/navigation/animation/level control.

## Flutter structure
`lib/main.dart`, `screens/`, `models/`, `services/`, `widgets/`; no unnecessary domain/repository layers.

## Firestore
`users/{uid}` and `users/{uid}/dajareEntries/{entryId}`. Trusted result fields are server-generated.

## Errors
Backend: `unauthenticated`, `invalid_input`, `unsafe_input`, `rate_limited`, `ai_unavailable`, `invalid_ai_response`, `internal_error`.
Flutter-local: `network_error`. Never show codes to children.

## Auth timing
Tasks 04–07 may prototype progressively. Task 10 formalizes Anonymous Auth/persistence. Production requires Auth + App Check + reasonable abuse/cost protection.
