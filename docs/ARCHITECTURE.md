# ARCHITECTURE.md

## 1. Architecture Goals

The architecture should be:

- Simple
- Easy for a beginner to maintain
- Shared across iOS and Android
- Secure for API secrets
- Suitable for a child-facing app
- Easy to extend without premature complexity

Avoid Clean Architecture, BLoC, heavy dependency injection, or other large patterns unless the project later demonstrates a real need.

## 2. High-Level Architecture

```text
┌─────────────────────┐
│ Flutter App         │
│ iOS / Android       │
└──────────┬──────────┘
           │
           │ HTTPS / Callable Function
           ▼
┌─────────────────────┐
│ Firebase Functions  │
│                     │
│ - validation        │
│ - safety checks     │
│ - Gemini request    │
│ - response parsing  │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────┐
│ Gemini API          │
└─────────────────────┘

Flutter App
     │
     ├──────────────→ Firebase Authentication
     │
     └──────────────→ Cloud Firestore
```

## 3. Responsibility Split

### Flutter

Responsible for:

- UI
- Navigation
- Input
- Loading / error states
- Character reactions
- Local presentation rules
- Calling Firebase Functions
- Reading/writing allowed Firestore data

Flutter must NOT:

- Store Gemini API keys
- Call Gemini directly
- Trust raw AI output without backend validation

### Firebase Functions

Responsible for:

- Request validation
- Authentication checks when required
- Abuse / rate-limit strategy when introduced
- Gemini API call
- AI prompt management
- Response schema validation
- Safety filtering
- Returning normalized JSON to Flutter

### Gemini

Responsible for:

- Understanding the Japanese input
- Identifying likely ダジャレ word pairs
- Evaluating wordplay
- Producing a short explanation

Gemini should not control application behavior directly.

## 4. Suggested Flutter Structure

Initial structure:

```text
lib/
├── main.dart
├── screens/
│   ├── home_screen.dart
│   ├── dajare_input_screen.dart
│   ├── result_screen.dart
│   ├── daily_topic_screen.dart
│   └── collection_screen.dart
├── services/
│   ├── dajare_service.dart
│   └── firestore_service.dart
├── models/
│   ├── dajare_result.dart
│   └── dajare_entry.dart
└── widgets/
    ├── score_card.dart
    └── character_reaction.dart
```

Do not create extra repository/domain/use-case layers unless they become necessary.

## 5. Firebase Functions Structure

Suggested starting point:

```text
functions/
├── src/
│   ├── index.ts
│   ├── dajare/
│   │   ├── judgeDajare.ts
│   │   ├── prompt.ts
│   │   └── schema.ts
│   └── safety/
│       └── contentSafety.ts
├── package.json
└── tsconfig.json
```

If this is too large for the initial implementation, start with fewer files and split only when `index.ts` becomes difficult to maintain.

## 6. Main API Contract

Conceptual function:

```text
judgeDajare
```

Request:

```json
{
  "text": "パンダがパンだ！"
}
```

Response:

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

The exact contract is defined in `AI_SPEC.md`.

## 7. Firestore — Initial Data Model

Keep the first version minimal.

Suggested user collection:

```text
users/{uid}
```

Possible fields:

```text
createdAt
updatedAt
```

Dajare entries:

```text
users/{uid}/dajareEntries/{entryId}
```

Possible fields:

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

Daily topics can initially be:

- bundled in the app, or
- stored in Firestore later.

Do not create a complex CMS for daily topics in MVP.

## 8. Authentication

Firebase Authentication is part of the planned stack.

However, authentication should not block early development of the core AI flow.

Recommended sequence:

1. Build core local UI.
2. Connect Firebase Functions.
3. Validate AI judging.
4. Add persistence.
5. Add authentication where persistence / production access requires it.

Anonymous authentication can be considered for a child-facing MVP because it avoids collecting unnecessary personal information, but the final choice should be reviewed before production.

## 9. Secrets

Gemini credentials must be stored on the backend.

Never commit:

- Gemini API key
- Service-account secrets
- private `.env` files containing production secrets

Use the Firebase / Google-supported secret-management mechanism used by the Functions implementation.

## 10. Error Handling

Flutter should receive normalized, non-sensitive errors.

Examples:

```text
network_error
invalid_input
unsafe_input
ai_unavailable
invalid_ai_response
unknown_error
```

Child-facing UI should show friendly messages such as:

```text
うまく聞き取れなかったみたい。
もう一度ためしてみてね！
```

Never display stack traces, API errors, or internal Gemini responses to children.

## 11. Testing Strategy

### Flutter

At minimum:

- Model parsing tests
- Service tests where practical
- Widget tests for core result states

### Functions

At minimum:

- Request validation
- AI response schema validation
- Score range validation
- Unsafe/invalid response fallback

## 12. Development Milestones

### Milestone 1 — Core pipeline

```text
Flutter text input
→ Firebase Function
→ Gemini
→ structured JSON
→ result screen
```

### Milestone 2 — Product loop

```text
daily topic
+ collection
+ persistence
```

### Milestone 3 — UX improvements

```text
speech input
+ richer character reactions
+ simple rewards
```

### Milestone 4 — Release readiness

```text
child safety
+ privacy
+ production Firebase rules
+ Android/iOS testing
+ store preparation
```
