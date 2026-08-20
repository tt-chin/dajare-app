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

When asked `Task XX`, read relevant specs, inspect repo, implement only XX, run checks, report changed files/commands/results/manual steps, then stop.
