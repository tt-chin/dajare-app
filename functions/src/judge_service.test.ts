import assert from "node:assert/strict";
import test from "node:test";

import {judgeAndPersist} from "./judge_service";
import {JudgeResult} from "./judging";

const result: JudgeResult = {
  isDajare: false,
  score: 20,
  level: "cold",
  word1: "ねこ",
  word2: "かわいい",
  comment: "ことばの音をさがしてみよう！",
};

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
