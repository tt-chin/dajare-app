// Only known status codes may enter logs; never stringify provider errors.
const STATUS_CODES = new Set([
  "cancelled", "unknown", "invalid-argument", "deadline-exceeded",
  "not-found", "already-exists", "permission-denied", "resource-exhausted",
  "failed-precondition", "aborted", "out-of-range", "unimplemented",
  "internal", "unavailable", "data-loss", "unauthenticated",
]);

export function safeErrorCode(error: unknown): number | string {
  if (typeof error !== "object" || error === null || !("code" in error)) {
    return "unknown";
  }

  const code: unknown = error.code;
  if (typeof code === "number" && Number.isInteger(code) &&
      code >= 1 && code <= 16) {
    return code;
  }
  if (typeof code === "string") {
    if (["app/no-app", "app/invalid-app-options", "app/invalid-credential",
      "app/duplicate-app", "firestore/invalid-credential",
      "firestore/missing-dependencies"].includes(code)) return code;
    const status = code.replace(/^firestore\//, "");
    if (STATUS_CODES.has(status)) return status;
  }
  return "unknown";
}
