import assert from "node:assert/strict";
import test from "node:test";

import {
  maxDajareLength,
  RequestValidationError,
  validateJudgeRequest,
} from "./validation";

test("accepts and trims valid text", () => {
  assert.equal(validateJudgeRequest({text: " パンダがパンだ！ "}), "パンダがパンだ！");
});

test("rejects a non-object payload", () => {
  assert.throws(() => validateJudgeRequest(null), RequestValidationError);
});

test("rejects a missing or non-string text", () => {
  assert.throws(() => validateJudgeRequest({}), RequestValidationError);
  assert.throws(
    () => validateJudgeRequest({text: 92}),
    RequestValidationError,
  );
});

test("rejects empty text", () => {
  assert.throws(
    () => validateJudgeRequest({text: "   "}),
    RequestValidationError,
  );
});

test("rejects text over the maximum length", () => {
  assert.throws(
    () => validateJudgeRequest({text: "あ".repeat(maxDajareLength + 1)}),
    RequestValidationError,
  );
});
