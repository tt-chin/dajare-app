# DEVELOPMENT_PLAN.md — Specification Freeze v1
Codex implements one task at a time and stops for review.

01 Flutter initialization — minimal iOS/Android app; no Firebase/Gemini/final UI.
02 Structure + Home — frozen three Home actions.
03 Text input — validation/loading-ready/mock result.
04 Firebase Flutter — initialize/configure Firebase; no Gemini client secret.
05 Functions foundation — Flutter → callable → `Hello Dajare!`.
06 Gemini — Functions → Gemini via backend secret/structured test.
07 AI judging — AI/PROMPT specs, schema/range/level/safe fallback.
08 Result UI — score/reaction/character/comment/word pair/Try Again.
09 今日のお題 — static topic + one-step hint, reuse core flow.
10 Anonymous Auth + Firestore — restrictive rules; production callable auth.
11 図鑑 — persist/read own validated server-controlled results.
12 Japanese speech — permission/recognition into same text pipeline.
13 Safety hardening — safety, App Check, rules, logging, rate/cost/errors.
14 Android/iOS validation — Android emulator/device; iOS macOS/cloud/TestFlight path.
15 Release — assets/privacy/config/builds/current Apple/Google policy review.

Milestones: A=01–03; B=04–08; C=09–11; D=12–14; E=15.

## Task 14 progress
- iOS simulator (iPhone 17 Pro, iOS 26.5, Xcode 26.6): builds, launches, reaches Home (Firebase init + App Check + Anonymous Auth pass).
- Build fixes: iOS deployment target 13.0 → 15.0 (Firebase plugins require 15.0); `cloud_functions` 6.3.6 → 6.4.0 (6.3.6 + `firebase_core` 4.14.0 fail Swift compile: redundant `FlutterError: Error`); `GoogleService-Info.plist` added to Runner target resources (was not bundled).
- Local setup note: stale CocoaPods CDN index needs `pod repo update`.
- Keep FlutterFire plugins upgraded together; mismatched native versions break the iOS build.
- Physical iPhone (iPhone 13 mini, iOS 26.6.1, USB): signs with `DEVELOPMENT_TEAM` N75N3Q3M5J, builds, installs, launches.
- App Check: device log shows 403 `Firebase App Check API has not been used in project 416889139850 before or it is disabled`. `judgeDajare` has `enforceAppCheck: false` (`functions/src/index.ts`), so calls should not be blocked. Enabling the API and registering a debug token (never commit it) are pending before enforcement.
- Physical iPhone: `judgeDajare` end-to-end works (score/reaction/comment/word pair shown).
- 図鑑 empty after a successful judgement: resolved. The Admin SDK default app was never created when the Functions SDK already had a named app, so `getFirestore()` failed and the save error was swallowed by `onSaveFailure`. Fixed in `067125f` (`getDefaultFirestore` in `functions/src/firestore_client.ts`, also used by `rate_limit.ts`, plus safe diagnostics); deployed and verified on iPhone (new judgement appears in 図鑑). Entries judged before the deploy were never saved.
- Scope decision: validate iOS only; Android validation is out of scope for now.
- Speech input fixed and verified on device: recognition kept running because the UI left `listening` on the first partial result and no `listenFor`/`pauseFor` was set, so text piled up across sessions. Now auto-stops (10s/3s), manual stop works, listeners are rebound on the `SpeechToText` singleton, and no-speech (`error_no_match`/`error_speech_timeout`) shows a retry message instead of "mic unavailable".
- Debug builds crash (SIGBUS, KERN_CODESIGN_ERROR) if the app keeps running after `flutter run` disconnects; keep the debugger attached or use `--release` for untethered tests.
- Not yet verified: Android (no Android SDK locally), TestFlight path.

When asked `Task XX`, read relevant specs, inspect repo, implement only XX, run checks, report changed files/commands/results/manual steps, then stop.
