import assert from "node:assert/strict";
import test from "node:test";
import {deleteApp, getApp, initializeApp} from "firebase-admin/app";
import {getDefaultFirestore} from "./firestore_client";
import {JudgeStage, safeDiagnostics} from "./diagnostics";

test("initializes default app even when the Functions SDK has a named app", async () => {
  const named = initializeApp({projectId: "diagnostic-test"},
    "__FIREBASE_FUNCTIONS_SDK__");
  const stages: JudgeStage[] = [];
  try {
    assert.throws(() => getApp(), {code: "app/no-app"});
    const firestore = getDefaultFirestore((stage) => stages.push(stage));
    assert.equal(getApp().name, "[DEFAULT]");
    assert.equal(getDefaultFirestore(() => {}), firestore);
    assert.equal(getApp(named.name), named);
    assert.deepEqual(stages, ["admin_app_init", "firestore_client_init"]);
  } finally {
    await deleteApp(named);
    await deleteApp(getApp());
  }
});

test("reports missing default app without leaking error message", () => {
  const error = Object.assign(new Error("private detail"), {code: "app/no-app"});
  assert.deepEqual(safeDiagnostics(error, "firestore_client_init"), {
    stage: "firestore_client_init", errorType: "Error",
    errorCode: "app/no-app", errorCategory: "default_app_missing",
  });
});
