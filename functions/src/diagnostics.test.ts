import assert from "node:assert/strict";
import test from "node:test";
import {safeDiagnostics, JudgeStage} from "./diagnostics";
import {saveTrustedDajareEntry} from "./dajare_entry_store";

test("classifies known messages without exposing their private contents", () => {
  const cases = [
    ["Could not load the default credentials: secret", "credentials_unavailable"],
    ["Unable to detect a Project Id: private", "project_configuration"],
    ["Cannot find module '/private/path'", "missing_dependency"],
    ["The database private does not exist", "database_missing"],
    ["API has not been used before or it is disabled", "api_disabled"],
    ["PERMISSION_DENIED: private", "permission_denied"],
    ["Cannot encode value: private", "invalid_firestore_data"],
  ];
  for (const [message, category] of cases) {
    const error = new Error(message);
    error.name = "private-custom-name";
    const diagnostic = safeDiagnostics(error, "firestore_init");
    assert.deepEqual(diagnostic, {
      stage: "firestore_init", errorType: "unknown",
      errorCode: "unknown", errorCategory: category,
    });
  }
  assert.equal(safeDiagnostics(null, "validation").errorCategory, "unclassified");
  assert.equal(safeDiagnostics(new Error("child text token"), "quota_read")
    .errorCategory, "unclassified");
});

test("classifies status codes even without a provider message", () => {
  for (const [code, category] of [
    [7, "permission_denied"], [4, "deadline_exceeded"],
    [14, "service_unavailable"],
  ] as const) {
    assert.equal(safeDiagnostics({code}, "quota_write").errorCategory, category);
  }
});

test("entry write failure retains its stage and original error", async () => {
  const stages: JudgeStage[] = [];
  const failure = new Error("private storage detail");
  await assert.rejects(saveTrustedDajareEntry("test-user", "test-text", {
    isDajare: false, score: 20, level: "cold",
    word1: "", word2: "", comment: "test",
  }, {
    serverTimestamp: () => 1,
    write: async () => { throw failure; },
  }, (stage) => stages.push(stage)), (error) => error === failure);
  assert.deepEqual(stages, ["entry_write"]);
});
