# FIREBASE_SPEC.md — Specification Freeze v1
## Stack
Anonymous Firebase Auth, Firestore, Functions 2nd gen, App Check. No extra Firebase products without need.

## judgeDajare
HTTPS Callable. Validates auth/App Check/request/input/safety, calls Gemini using backend secret, parses structured output, validates score/schema, calculates `level`, applies output safety, writes trusted result, returns normalized response.

## Auth
MVP uses Anonymous Auth. Production rejects unauthenticated calls and never trusts client-supplied UID.

## Firestore
`users/{uid}`; `users/{uid}/dajareEntries/{entryId}`.
Trusted judged-result fields are server-controlled. Client cannot create/update fake scores. User reads only own data. Deny by default.

## Secret
Use Firebase/Google Cloud Secret Manager, e.g. `GEMINI_API_KEY`; never commit or place in Flutter/logs/issues/examples.

## App Check
Before release: Android Play Integrity; iOS supported App Attest/Apple configuration. Debug provider only in development. Observe traffic before enforcement.

Task 13 prepares Flutter providers (`debug` in debug builds, Play Integrity on Android production, App Attest with DeviceCheck fallback on Apple production). Console enforcement remains OFF until Task 14 device validation. Register local debug tokens in Firebase Console; never commit them.

## Rate protection
`judgeDajare` uses an Admin SDK Firestore transaction at `users/{uid}/rateLimits/judgeDajare`: 5-second per-UID cooldown and 100 accepted attempts per UTC day. This server-only document is denied to clients by the default rules. Validation and safety checks run before quota consumption; quota consumption runs before Gemini.

## Errors
`unauthenticated`, `invalid_input`, `unsafe_input`, `rate_limited`, `ai_unavailable`, `invalid_ai_response`, `internal_error`.

## Privacy/logging/cost
Minimize stored data; avoid raw prompt/response dumps and full user text in production logs by default. Add reasonable per-UID/cooldown/daily controls as needed, input limits, App Check and monitoring. Use Auth/Functions/Firestore emulators where practical.
