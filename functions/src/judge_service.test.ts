import assert from "node:assert/strict";
import test from "node:test";

import {judgeAndPersist} from "./judge_service";
import {JudgeResult} from "./judging";
import {safeDiagnostics} from "./diagnostics";

const result: JudgeResult = {
  isDajare: false,
  score: 20,
  level: "cold",
  word1: "ねこ",
  word2: "かわいい",
  comment: "ことばの音をさがしてみよう！",
};

test("cleanup runs after save and uses exactly the authenticated UID", async () => {
  const calls: string[] = [];
  const returned = await judgeAndPersist("user-1", "text", {
    judge: async () => result,
    save: async (uid) => { calls.push(`save:${uid}`); },
    cleanup: async (uid) => { calls.push(`cleanup:${uid}`); },
    onSaveFailure: () => assert.fail("save failed"),
    onCleanupFailure: () => assert.fail("cleanup failed"),
  });
  assert.equal(returned, result);
  assert.deepEqual(calls, ["save:user-1", "cleanup:user-1"]);
});

test("cleanup failure returns the unchanged result and produces only safe diagnostics", async () => {
  let diagnostic: unknown;
  const returned = await judgeAndPersist("user-1", "private child input", {
    judge: async () => result,
    save: async () => {},
    cleanup: async () => { throw Object.assign(new Error("private child input token"), {code: 7}); },
    onSaveFailure: () => assert.fail("must not report cleanup as save failure"),
    onCleanupFailure: (error) => { diagnostic = safeDiagnostics(error, "entry_cleanup"); },
  });
  assert.equal(returned, result);
  assert.deepEqual(diagnostic, {stage: "entry_cleanup", errorType: "Error",
    errorCode: 7, errorCategory: "permission_denied"});
});

test("save failure never starts cleanup", async () => {
  const returned = await judgeAndPersist("user-1", "text", {
    judge: async () => result,
    save: async () => { throw new Error("save failed"); },
    cleanup: async () => assert.fail("must not delete after a failed save"),
    onSaveFailure: () => {},
  });
  assert.equal(returned, result);
});

test("saves the trusted result after successful judging", async () => {
  let savedUid = "";
  let savedText = "";

  const returned = await judgeAndPersist("user-1", "ねこがかわいい", {
    judge: async () => result,
    save: async (uid, text, savedResult) => {
      savedUid = uid;
      savedText = text;
      assert.equal(savedResult, result);
    },
    onSaveFailure: () => assert.fail("save should not fail"),
  });

  assert.equal(returned, result);
  assert.equal(savedUid, "user-1");
  assert.equal(savedText, "ねこがかわいい");
});

test("returns the AI result when persistence fails", async () => {
  let failureWasHandled = false;

  const returned = await judgeAndPersist("user-1", "ねこがかわいい", {
    judge: async () => result,
    save: async () => {
      throw new Error("internal Firestore detail");
    },
    onSaveFailure: () => {
      failureWasHandled = true;
    },
  });

  assert.equal(returned, result);
  assert.equal(failureWasHandled, true);
});

test("checks rate protection before calling Gemini", async () => {
  let judgeCalled = false;
  await assert.rejects(
    judgeAndPersist("user-1", "パンダがパンだ！", {
      consumeQuota: async (uid) => {
        assert.equal(uid, "user-1");
        throw new Error("limited");
      },
      judge: async () => {
        judgeCalled = true;
        return result;
      },
      save: async () => {},
      onSaveFailure: () => {},
    }),
  );
  assert.equal(judgeCalled, false);
});
