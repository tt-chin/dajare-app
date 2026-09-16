import {safeErrorCode} from "./error_code";

export type JudgeStage = "validation" | "firestore_init" | "quota_read" |
  "quota_write" | "ai_judge" | "entry_write" |
  "admin_app_init" | "firestore_client_init" | "entry_cleanup";
export type ReportStage = (stage: JudgeStage) => void;

// Match locally, but emit only fixed labels, never provider messages or stacks.
export function safeDiagnostics(error: unknown, stage: JudgeStage) {
  const errorCode = safeErrorCode(error);
  const message = error instanceof Error ? error.message.slice(0, 4096) : "";
  let errorCategory = "unclassified";
  if (errorCode === "app/no-app") {
    errorCategory = "default_app_missing";
  } else if (errorCode === "app/invalid-app-options") {
    errorCategory = "app_configuration";
  } else if (/Could not load the default credentials|default credentials were not found/i
    .test(message)) {
    errorCategory = "credentials_unavailable";
  } else if (/Unable to detect a Project Id|project.?id.*must be.*string/i
    .test(message)) {
    errorCategory = "project_configuration";
  } else if (/Cannot find module|Failed to import the Cloud Firestore client/i
    .test(message)) {
    errorCategory = "missing_dependency";
  } else if (/database.*does not exist/i.test(message)) {
    errorCategory = "database_missing";
  } else if (/has not been used.*before or it is disabled|SERVICE_DISABLED/i
    .test(message)) {
    errorCategory = "api_disabled";
  } else if (errorCode === 7 || errorCode === "permission-denied" ||
    /PERMISSION_DENIED|Missing or insufficient permissions/i.test(message)) {
    errorCategory = "permission_denied";
  } else if (/Cannot use.*undefined.*Firestore|Cannot encode value|not a valid Firestore/i
    .test(message)) {
    errorCategory = "invalid_firestore_data";
  } else if (errorCode === 4 || errorCode === "deadline-exceeded") {
    errorCategory = "deadline_exceeded";
  } else if (errorCode === 14 || errorCode === "unavailable") {
    errorCategory = "service_unavailable";
  }
  const safeNames = new Set([
    "Error", "TypeError", "RangeError", "FirebaseError",
    "GeminiUnavailableError", "InvalidGeminiResponseError",
  ]);
  return {
    stage,
    errorType: error instanceof Error && safeNames.has(error.name) ?
      error.name : "unknown",
    errorCode,
    errorCategory,
  };
}
