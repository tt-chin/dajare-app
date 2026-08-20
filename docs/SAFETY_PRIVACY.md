# SAFETY_PRIVACY.md — Specification Freeze v1
Child safety/privacy are product requirements.

## Data
Do not require real name, school, address, birthday, email, phone, or public profile. MVP uses Anonymous Auth. Store only gameplay/collection data needed for the feature; avoid unnecessary device IDs and permanent raw AI dumps.

## Social
No public chat, messaging, friends, public posting/ranking, social feed, or photo upload. Any future addition requires separate safety/privacy review.

## AI
Do not generate/expand adult/sexual content, graphic violence, self-harm, hate, dangerous instructions, bullying, frightening age-inappropriate content, or personal-data requests. Unsafe input is redirected, not repeated/expanded.

## UX/backend
No shaming or harsh failure language. Never expose prompts, stack traces, Firebase IDs, provider errors, or secrets. Treat Flutter as untrusted; validate auth/App Check/input/output/ownership server-side.

## Logging/retention
Never log secrets/tokens. Avoid full child input by default. Before release define deletion for saved user-created content and operational-log retention.

## Analytics/ads
Do not add analytics, ads, tracking, attribution, or third-party SDKs by default; each requires child/privacy review and disclosure updates.

## Release gate
Re-check current Apple/Google child/privacy requirements and applicable target-market law before release. Privacy disclosures must match actual behavior.
