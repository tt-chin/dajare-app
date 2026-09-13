import assert from "node:assert/strict";
import test from "node:test";

import {safeErrorCode} from "./error_code";

test("keeps numeric Firestore status codes without provider details", () => {
  const error = Object.assign(new Error("private child input"), {
    code: 7,
    details: "private token",
  });
  assert.equal(safeErrorCode(error), 7);
  assert.equal(safeErrorCode({code: "firestore/permission-denied"}),
    "permission-denied");
  assert.equal(safeErrorCode({code: "unavailable"}), "unavailable");
});

test("does not log arbitrary strings, objects or invalid numeric codes", () => {
  for (const code of ["private token", {token: "secret"}, 0, 17, 7.5, NaN]) {
    assert.equal(safeErrorCode({code}), "unknown");
  }
  for (const error of [new Error("private input"), null, undefined, "secret"]) {
    assert.equal(safeErrorCode(error), "unknown");
  }
});
