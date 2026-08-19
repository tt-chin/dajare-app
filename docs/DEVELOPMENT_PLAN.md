# DEVELOPMENT_PLAN.md

## Purpose

This document defines the implementation order for the child-facing Japanese ダジャレ app MVP.

Codex must work on **one task at a time** unless explicitly instructed otherwise. Before implementation, read `AGENTS.md`, `docs/PRODUCT.md`, `docs/ARCHITECTURE.md`, `docs/AI_SPEC.md`, and this file.

For every task: inspect the repository first, preserve working code, make the smallest reasonable change, avoid unnecessary packages/architecture, keep iOS/Android shared where practical, never put Gemini secrets in Flutter, run applicable checks, and do not automatically continue to the next task.

---

# Phase 1 — Flutter Foundation

## Task 01 — Initialize Flutter Project

**Goal:** Create the basic Flutter application.

**Scope**
- Initialize Flutter in this repository.
- Generate Android and iOS targets.
- Use an appropriate application/package identifier.
- Keep dependencies minimal.
- Replace the default counter sample with a minimal app shell.

**Expected result:** App launches and displays `ダジャレアプリ`.

**Do not implement:** Firebase, Gemini, Authentication, Firestore, speech recognition, final UI, or a state-management framework.

**Validation**
```bash
flutter pub get
dart format .
flutter analyze
flutter test
```

On Windows, also confirm `flutter run` when an emulator/device is available.

**Completion criteria**
- Flutter project builds.
- Android/iOS targets exist.
- No blocking analyze errors.
- Existing specification documents remain intact.

---

## Task 02 — Basic App Structure and Home Screen

**Goal:** Create a simple maintainable structure and home screen.

Suggested structure:
```text
lib/
├── main.dart
├── screens/
│   └── home_screen.dart
├── models/
├── services/
└── widgets/
```

Home actions:
- ダジャレを入力する
- 今日のお題
- ダジャレ図鑑

UX: large touch targets, simple Japanese, child-friendly layout, minimal text.

**Do not implement:** Gemini, Firebase persistence, daily-topic logic, speech input, complex animations.

**Completion criteria:** Home launches, actions are clear, navigation remains simple, and no unnecessary architecture is introduced.

---

## Task 03 — ダジャレ Text Input

**Goal:** Allow text entry and submission.

Implement:
- Text field
- Submit button
- Empty validation
- Reasonable maximum length
- Loading-ready state
- Temporary local mock result

Example: `パンダがパンだ！` → `92点 / うまい！`

**Do not implement:** Gemini, Functions, Firestore, speech.

**Completion criteria:** Home → input → mock result works and invalid empty input is rejected.

---

# Phase 2 — Firebase and AI Pipeline

## Task 04 — Add Firebase to Flutter

**Goal:** Connect Flutter to Firebase.

Implement Firebase initialization and Android configuration; prepare iOS configuration without requiring a Windows iOS build.

**Important:** No Gemini credentials in Flutter.

**Do not implement:** Gemini call, Firestore persistence, authentication UI.

**Completion criteria:** Firebase initializes successfully on Android and `flutter analyze` passes.

---

## Task 05 — Firebase Functions Foundation

**Goal:** Create a minimal backend callable from Flutter.

Initial flow:
```text
Flutter → Firebase Function → "Hello Dajare!" → Flutter
```

Validate request shape and do not expose internal stack traces.

**Completion criteria:** Flutter can invoke the function and handle success/failure.

---

## Task 06 — Connect Gemini API

**Goal:** Securely call Gemini from Firebase Functions.

Flow:
```text
Firebase Functions → Gemini API → structured response
```

Use an appropriate backend secret mechanism. Start with a controlled test prompt.

**Never:** Flutter → Gemini directly; commit an API key.

**Completion criteria:** Function calls Gemini successfully, secret is not committed, invalid AI responses fail safely.

---

## Task 07 — Implement ダジャレ AI Judging

**Goal:** Implement `AI_SPEC.md`.

Request:
```json
{"text":"パンダがパンだ！"}
```

Normalized response:
```json
{
  "isDajare": true,
  "score": 92,
  "level": "うまい！",
  "word1": "パンダ",
  "word2": "パンだ",
  "comment": "「パンダ」と「パンだ」の音がそっくり！"
}
```

Backend must validate input/output, enforce score 0–100, derive `level` from score, normalize malformed responses, and provide safe fallback behavior.

Test representative cases:
- パンダがパンだ！
- 布団が吹っ飛んだ
- ねこがかわいい
- Empty/too-long input
- Invalid Gemini response

**Completion criteria:** Flutter → Functions → Gemini → validated result works without crashing on invalid output.

---

# Phase 3 — Core Product Experience

## Task 08 — Result Screen and Character Reaction

Display score, reaction, detected word pair, comment, character reaction, and Try Again.

Score mapping:

| Score | Reaction |
|---|---|
| 0–39 | さむ～い！🥶 |
| 40–69 | いいね！😆 |
| 70–89 | うまい！🤣 |
| 90–99 | 天才！🤩 |
| 100 | 伝説のダジャレ王！👑 |

Low scores must remain encouraging.

**Completion criteria:**
```text
Home → Input → AI judging → Result → Try again
```

This is the first major MVP milestone.

---

## Task 09 — 今日のお題

Implement a simple daily-topic screen and hint.

Initial categories:
- どうぶつ
- たべもの
- がっこう
- のりもの
- きせつ
- おばけ

Prefer bundled/static topic data initially. Hint should guide without immediately giving the complete answer.

**Completion criteria:** Topic → hint → existing judging flow works.

---

# Phase 4 — Persistence

## Task 10 — Firebase Authentication and Firestore Foundation

**Goal:** Minimal child-appropriate identity and persistence.

Anonymous Firebase Authentication is the preferred MVP candidate unless implementation requirements justify another approach.

Suggested data:
```text
users/{uid}
users/{uid}/dajareEntries/{entryId}
```

Do not request unnecessary personal data such as name, birthday, school, address, or email. Use restrictive Firestore Security Rules.

**Completion criteria:** Identity works, data is scoped to the user, cross-user private access is blocked.

---

## Task 11 — ダジャレ図鑑

Save only necessary fields:
```text
text
score
level
word1
word2
comment
category
createdAt
```

Show previous entries using a simple card/list.

**Completion criteria:** Results can be saved, survive restart, and only the current user's entries are accessible.

---

# Phase 5 — UX Expansion

## Task 12 — Japanese Speech Input

Add Japanese speech recognition, microphone permission handling, clear recording state, and recognition failure messages.

Speech must reuse the existing text judging pipeline.

Example failure:
`うまく聞き取れなかったみたい。もう一度ためしてみてね！`

**Completion criteria:** Speech populates/submits text, denial/failure is handled, text input remains available.

---

# Phase 6 — Safety and Quality

## Task 13 — Child Safety and Error Handling Hardening

Review AI safety, validation, inappropriate input, Firebase Rules, error messages, logging, data minimization, abuse prevention, and API cost protection.

Unsafe input must not cause Gemini to creatively expand inappropriate content.

Suggested redirect:
`ほかのことばでダジャレを作ってみよう！どうぶつや食べもののお題がおすすめだよ。`

**Completion criteria:** Common unsafe/invalid cases are tested, internal errors stay hidden, sensitive data is not unnecessarily logged, and backend cost/abuse protections are reasonable.

---

## Task 14 — Android and iOS Validation

Android: emulator plus a real device when available.

iOS: use an appropriate macOS/cloud/TestFlight workflow for final build/validation because the primary development environment is Windows.

Test navigation, input, Firebase, AI, Firestore, speech permissions, network failures, and screen sizes.

**Completion criteria:** No blocking Android issues; iOS validation path confirmed; platform-specific issues documented/fixed where practical.

---

# Phase 7 — Release

## Task 15 — Store Release Preparation

Prepare:
- App name/icon
- Screenshots
- Store description
- Privacy policy
- Production Firebase config/rules
- Version/build numbers
- Release builds
- Child-directed app requirements
- Privacy/data/AI disclosures

Before this task, check current official Apple and Google requirements because store policies change.

**Completion criteria:** Production builds/assets/privacy information are ready for submission.

---

# Milestones

**Milestone A — Local Prototype:** Tasks 01–03  
Child can type a ダジャレ and see a mock result.

**Milestone B — AI Prototype:** Tasks 04–08  
`Input → Firebase Functions → Gemini → AI判定 → Result`

**Milestone C — MVP:** Tasks 09–11  
Daily topic and persistent collection.

**Milestone D — Release Candidate:** Tasks 12–14  
Speech, safety hardening, cross-platform validation.

**Milestone E — Release:** Task 15  
Ready for App Store / Google Play submission.

---

# Future — Not Initial MVP

Do not implement unless explicitly promoted:
- 親子ダジャレ対決
- Character unlocks
- Collection cards
- Seasonal events
- Character packs
- Public rankings
- Friends
- Public posts
- Chat/social feed

Public/social child features require a separate safety/privacy design review.

---

# Codex Task Execution Template

When instructed:

`DEVELOPMENT_PLAN.md の Task XX を実装してください。`

Codex should:
1. Read relevant specifications.
2. Inspect current repository state.
3. Implement only Task XX.
4. Run relevant validation.
5. Report files changed, implementation, commands, results, limitations/manual steps.
6. Do not automatically continue to the next task.
